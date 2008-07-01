module Halcyon
  
  # The core of Halcyon on the server side is the Halcyon::Application class
  # which handles dispatching requests and responding with appropriate messages
  # to the client (which can be specified).
  # 
  # Manages shutting down and starting up hooks, routing, dispatching, etc.
  # Also restricts the requests to acceptable clients, defaulting to all.
  # 
  class Application
    
    autoload :Hooks, 'halcyon/application/hooks'
    autoload :Router, 'halcyon/application/router'
    
    include Exceptions
    include Hooks
    
    # Initializes the app:
    # * runs startup hooks
    # * registers shutdown hooks
    # 
    def initialize
      self.logger.info "Starting up..."
      
      Halcyon.hooks[:startup].each {|hook| hook.call(Halcyon.config) }
      
      # clean after ourselves and get prepared to start serving things
      self.logger.debug "Starting GC."
      GC.start
      
      self.logger.info "Started. PID is #{$$}"
      
      at_exit do
        self.logger.info "Shutting down #{$$}."
        Halcyon.hooks[:shutdown].each {|hook| hook.call(Halcyon.config) }
        self.logger.info "Done."
      end
    end
    
    # Sets up the request and response objects for use in the controllers and
    # dispatches requests. Renders response data as JSON for response.
    #   +env+ the request environment details
    # 
    # The internal router (which inherits from the Merb router) is sent the
    # request to pass back the route for the dispatcher to call. This route is
    # stored in <tt>env['halcyon.route']</tt> (as per the Rack spec).
    # 
    # Configs
    #   <tt>Halcyon.config[:allow_from]</tt> #=> (default) <tt>:all</tt>
    #     :all              => does not restrict requests from any User-Agent
    #     :local            => restricts requests to only local requests (from
    #                          localhost, 0.0.0.0, 127.0.0.1)
    #     :halcyon_clients  => restricts to only Halcyon clients (identified by
    #                          User-Agent)
    # 
    # Exceptions
    #   If a request raises an exception that inherits from
    #   <tt>Halcyon::Exceptions::Base</tt> (<tt>NotFound</tt>, etc), then the
    #   response is sent with this information.
    #   If a request raises any other kind of <tt>Exception</tt>, it is logged
    #   as an error and a <tt>500 Internal Server Error</tt> is returned.
    # 
    # Returns [Fixnum:status, {String:header => String:value}, [String:body].to_json]
    # 
    def call(env)
      timing = {:started => Time.now}
      
      request = Rack::Request.new(env)
      response = Rack::Response.new
      
      response['Content-Type'] = "application/json"
      response['User-Agent'] = "JSON/#{JSON::VERSION} Compatible (en-US) Halcyon::Application/#{Halcyon.version}"
      
      begin
        acceptable_request!(env)
        
        env['halcyon.route'] = Router.route(request)
        result = dispatch(env)
      rescue Exceptions::Base => e
        result = {:status => e.status, :body => e.body}
        self.logger.info e.message
      rescue Exception => e
        result = {:status => 500, :body => 'Internal Server Error'}
        self.logger.error "#{e.message}\n\t" << e.backtrace.join("\n\t")
      end
      
      # This handles various sorts of response formats.
      # 
      # The primary format is <tt>{:status => 200, :body => ...}</tt> which
      # also supports a <tt>:headers</tt> entity (also a Hash).
      # 
      # If this format is not followed, we assume they've just returned data so
      # we package it up like normal and respond (for the user).
      # 
      # The one exception to the previous rule is if the data is in the
      # standard response structure [200, {}, 'OK'] or some such, we construct
      # the reply accordingly.
      # 
      response.status = 200 # we assume 200, but when specified get updated appropriately
      result = case result
      when Hash
        if result[:status] and result[:body]
          # {:status => 200, :body => 'OK'}
          # no coercion necessary
          result
        else
          # {*}
          {:status => 200, :body => result}
        end
      when Array
        if result[0].is_a?(Integer) and result[1].is_a?(Hash) and result[2]
          # [200, {}, 'OK'] format followed
          {:status => result[0], :headers => result[1], :body => result[2]}
        else
          # [*]
          {:status => 200, :body => result}
        end
      else
        # *
        {:status => 200, :body => result}
      end
      # set response data
      headers = result.delete(:headers) || {}
      response.status = result[:status]
      headers.each {|(header,val)| response[header] = val }
      response.write result.to_json
      
      timing[:finished] = Time.now
      # the rescue is necessary if for some reason the timing is faster than
      # system timing usec. this actually happens on Windows
      timing[:total] = ((((timing[:finished] - timing[:started])*1e4).round.to_f/1e4) rescue 0.01)
      timing[:per_sec] = (((1.0/(timing[:total]))*1e2).round.to_f/1e2)
      
      self.logger.info "[#{response.status}] #{URI.parse(env['REQUEST_URI'] || env['PATH_INFO']).path} (#{timing[:total]}s;#{timing[:per_sec]}req/s)"
      # self.logger << "Session ID: #{self.session.id}\n" # TODO: Implement session
      self.logger << "Params: #{filter_params_for_log(request, env).inspect}\n\n"
      
      response.finish
    end
    
    # Dispatches the controller and action according the routed request.
    #   +env+ the request environment details, including "halcyon.route"
    # 
    # If no <tt>:controller</tt> is specified, the default <tt>Application</tt>
    # controller is dispatched to.
    # 
    # Once the controller is selected and instantiated, the action is called,
    # defaulting to <tt>:default</tt> if no action is provided.
    # 
    # If the action called is not defined, a <tt>404 Not Found</tt> exception
    # will be raised. This will be sent to the client as such, or handled by
    # the Rack application container, such as the Rack Cascade middleware to
    # failover to another application (such as Merb or Rails).
    # 
    # Refer to Halcyon::Application::Router for more details on defining routes
    # and for where to get further documentation.
    # 
    # Returns (String|Array|Hash):body
    # 
    def dispatch(env)
      route = env['halcyon.route']
      # make sure that the right controller/action is called based on the route
      controller = case route[:controller]
      when NilClass
        # default to the Application controller
        ::Application.new(env)
      when String
        # pulled from URL, so camelize (from merb/core_ext) and symbolize first
        begin
          Object.const_get(route[:controller].camel_case.to_sym).new(env)
        rescue NameError => e
          raise NotFound.new
        end
      end
      
      # Establish the selected action, defaulting to +default+.
      action = (route[:action] || 'default').to_sym
      
      # Respond correctly that a non-existent action was specified if the
      # method does not exist.
      raise NotFound.new unless controller.methods.include?(action.to_s)
      
      # if no errors have occured up to this point, the route should be fully
      # valid and all exceptions raised should be treated as
      # <tt>500 Internal Server Error</tt>s, which is handled by <tt>call</tt>.
      controller._dispatch(action)
    end
    
    # def apply_filters(where, controller, action)
    #   self.logger.debug "Applying #{where.to_s} filters to #{controller.class.to_s}##{action.to_s}"
    #   if controller.filters[:all].include?(action)
    #     controller.filters[:all][action].select {|filter| filter[:apply] == where}.each do |filter|
    #       if filter[:filter_or_block].is_a?(Proc)
    #         filter[:filter_or_block].call
    #       else
    #         controller.send(filter[:filter_or_block])
    #       end
    #     end
    #   end
    #   if controller.filters[:only].include?(action)
    #     controller.filters[:only][action].select {|filter| filter[:apply] == where && filter}.each do |filter|
    #       controller.send(filter[:filter_or_block])
    #     end
    #   end
    #   controller.filters[:except].each do |(filters_not_for_action, filters)|
    #     unless filters_not_for_action == action
    #       filters.each do |filter|
    #         controller.send(filter[:filter_or_block])
    #       end
    #     end
    #   end
    # end
    
    # Filters unacceptable requests depending on the configuration of the
    # <tt>:allow_from</tt> option.
    # 
    # This method is not directly called by the user, instead being called
    # in the #call method.
    # 
    # Acceptable values include:
    #   <tt>:all</tt>:: allow every request to go through
    #   <tt>:halcyon_clients</tt>:: only allow Halcyon clients
    #   <tt>:local</tt>:: do not allow for requests from an outside host
    # 
    # Raises Forbidden
    # 
    def acceptable_request!(env)
      case Halcyon.config[:allow_from].to_sym
      when :all
        # allow every request to go through
      when :halcyon_clients
        # only allow Halcyon clients
        raise Forbidden.new unless env['USER_AGENT'] =~ /JSON\/1\.1\.\d+ Compatible \(en-US\) Halcyon::Client\(\d+\.\d+\.\d+\)/
      when :local
        # do not allow for requests from an outside host
        raise Forbidden.new unless ['localhost', '127.0.0.1', '0.0.0.0'].member? env["REMOTE_ADDR"]
      else
        logger.warn "Unrecognized allow_from configuration value (#{Halcyon.config[:allow_from].to_s}); use all, halcyon_clients, or local. Allowing all requests."
      end
    end
    
    # Assemble params for logging.
    # 
    # This method exists to be overridden or method-chained to filter out params
    # from being logged for applications with sensitive data like passwords.
    # 
    # Returns Hash:params_to_log
    # 
    def filter_params_for_log(request, env)
      request.params.merge(env['halcyon.route'])
    end
    
    class << self
      
      # Defines routes for the application.
      # 
      # Refer to Halcyon::Application::Router for documentation and resources.
      # 
      def route
        if block_given?
          Router.prepare do |router|
            Router.default_to yield(router) || {:controller => 'application', :action => 'not_found'}
          end
        end
      end
      
      #--
      # Boot Process
      #++
      
      # Used to keep track of whether the boot process has been run yet.
      attr_accessor :booted
      
      # Runs through the bootup process. This involves:
      # * establishing configuration directives
      # * loading required libraries
      # 
      def boot(&block)
        Halcyon.config ||= Halcyon::Config.new
        
        # Set application name
        Halcyon.app = Halcyon.config[:app] || Halcyon.root.split('/').last.camel_case
        
        # Load configuration files (when available)
        Dir.glob(%w(config app).map{|conf|Halcyon.paths[:config]/conf+'.{yml,yaml}'}).each do |config_file|
          Halcyon.config.load_from(config_file) if File.exist?(config_file)
        end
        
        # Run configuration files (when available)
        # These are unique in that they are Ruby files that we require so we
        # can get rid of YAML config files and use Ruby configuration files.
        Dir.glob(Halcyon.paths[:config]/'*.rb').each do |config_file|
          require config_file
        end
        
        # Yield to the block to handle boot configuration (and other tasks).
        Halcyon.config.use(&block) if block_given?
        
        # Setup logger
        if Halcyon.config[:logger]
          Halcyon.config[:logging] = (Halcyon.config[:logging] || Halcyon::Config.defaults[:logging]).merge({
            :type => Halcyon.config[:logger].class.to_s,
            :logger => Halcyon.config[:logger]
          })
        end
        Halcyon::Logging.set(Halcyon.config[:logging][:type])
        Halcyon.logger = Halcyon::Logger.setup(Halcyon.config[:logging])
        
        # Run initializers
        Dir.glob(%w(requires hooks routes *).map{|init|Halcyon.paths[:init]/init+'.rb'}).uniq.each do |initializer|
          self.logger.debug "Init: #{File.basename(initializer).chomp('.rb').camel_case}" if
          require initializer.chomp('.rb')
        end
        
        # Setup autoloads for Controllers found in Halcyon.root/'app' (by default)
        Dir.glob([Halcyon.paths[:controller]/'application.rb', Halcyon.paths[:controller]/'*.rb']).uniq.each do |controller|
          self.logger.debug "Load: #{File.basename(controller).chomp('.rb').camel_case} Controller" if
          require controller.chomp('.rb')
        end
        
        # Setup autoloads for Models found in Halcyon.root/'app'/'models' (by default)
        Dir.glob(Halcyon.paths[:model]/'*.rb').each do |model|
          self.logger.debug "Load: #{File.basename(model).chomp('.rb').camel_case} Model" if
          require model.chomp('.rb')
        end
        
        # Set to loaded so additional calls to boot are ignored (unless
        # forcefully loaded by ignoring this value).
        self.booted = true
      end
      
    end
    
  end
  
end
