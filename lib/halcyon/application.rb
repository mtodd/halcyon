module Halcyon
  
  # The core of Halcyon on the server side is the Halcyon::Application class
  # which handles dispatching requests and responding with appropriate messages
  # to the client (which can be specified).
  class Application
    include Exceptions
    
    autoload :Router, 'halcyon/application/router'
    
    attr_accessor :collection # collects values set in startup hook to set for controller
    attr_accessor :session
    
    DEFAULT_OPTIONS = {
      :root => Dir.pwd,
      :log_level => 'info',
      :allow_from => :all
    }
    
    def initialize
      self.logger.info "Starting up..."
      
      self.collection = {}
      
      self.hooks[:startup].call(Halcyon.config) if self.hooks[:startup]
      self.class.instance_variables.reject{|v| ['@hooks', '@inheritable_attributes'].include? v }.each{|v| self.collection[v] = self.class.instance_variable_get(v) }
      
      # clean after ourselves and get prepared to start serving things
      self.logger.debug "Starting GC."
      GC.start
      
      self.logger.info "Started. PID is #{$$}"
      
      at_exit do
        self.logger.info "Shutting down #{$$}."
        self.hooks[:shutdown].call(Halcyon.config) if self.hooks[:shutdown]
        self.logger.info "Done."
      end
    end
    
    def call(env)
      timing = {:started => Time.now}
      
      request = Rack::Request.new(env)
      response = Rack::Response.new
      
      response['Content-Type'] = "application/json" # "text/plain" for debugging maybe?
      response['User-Agent'] = "JSON/#{JSON::VERSION} Compatible (en-US) Halcyon::Application/#{Halcyon.version}"
      
      begin
        acceptable_request! env
        
        env['halcyon.route'] = Router.route(request)
        result = dispatch(env)
      rescue Exceptions::Base => e
        result = {:status => e.status, :body => e.body}
        self.logger.info e.message
      rescue Exception => e
        result = {:status => 500, :body => 'Internal Server Error'}
        self.logger.error "#{e.message}\n\t" << e.backtrace.join("\n\t")
      end
      
      response.status = result[:status]
      response.write result.to_json
      
      timing[:finished] = Time.now
      timing[:total] = (((timing[:finished] - timing[:started])*1e4).round.to_f/1e4)
      timing[:per_sec] = (((1.0/(timing[:total]))*1e2).round.to_f/1e2)
      
      self.logger.info "[#{response.status}] #{URI.parse(env['REQUEST_URI'] || env['PATH_INFO']).path} (#{timing[:total]}s;#{timing[:per_sec]}req/s)"
      # self.logger << "Session ID: #{self.session.id}\n" # TODO: Implement session
      self.logger << "Params: #{request.params.merge(env['halcyon.route']).inspect}\n\n"
      
      response.finish
    end
    
    def dispatch(env)
      route = env['halcyon.route']
      # make sure that the right controller/action is called based on the route
      controller = case route[:controller]
      when NilClass
        # default to the Application controller
        ::Application.new(env)
      when String
        # pulled from URL, so camelize (from merb/core_ext) and symbolize first
        Object.const_get(route[:controller].camel_case.to_sym).new(env)
      end
      
      self.collection.keys.each {|k| controller.instance_variable_set(k, self.collection[k]) }
      controller.send(route[:action].to_sym)
    end
    
    # Filters unacceptable requests depending on the configuration of the
    # <tt>:allow_from</tt> option.
    # Acceptable values include:
    # 
    #   <tt>:all</tt>:: allow every request to go through
    #   <tt>:halcyon_clients</tt>:: only allow Halcyon clients
    #   <tt>:local</tt>:: do not allow for requests from an outside host
    def acceptable_request!(env)
      case Halcyon.config[:allow_from].to_sym
      when :all
        # allow every request to go through
      when :halcyon_clients
        # only allow Halcyon clients
        raise Exception::Forbidden.new unless env['USER_AGENT'] =~ /JSON\/1\.1\.\d+ Compatible \(en-US\) Halcyon::Client\(\d+\.\d+\.\d+\)/
      when :local
        # do not allow for requests from an outside host
        raise Exceptions::Forbidden.new unless ['localhost', '127.0.0.1', '0.0.0.0'].member? env["REMOTE_ADDR"]
      else
        logger.warn "Unrecognized allow_from configuration value (#{Halcyon.config[:allow_from].to_s}); use all, halcyon_clients, or local. Allowing all requests."
      end
    end
    
    def logger
      Halcyon.logger
    end
    
    def hooks
      self.class.hooks
    end
    
    class << self
      
      attr_accessor :hooks
      
      def hooks
        @hooks ||= {}
      end
      
      def logger
        Halcyon.logger
      end
      
      def route
        if block_given?
          Router.prepare do |router|
            Router.default_to yield(router) || {:controller => 'application', :action => 'not_found'}
          end
        end
      end
      
      def startup &hook
        self.hooks[:startup] = hook
      end
      
      def shutdown &hook
        self.hooks[:shutdown] = hook
      end
      
    end
    
  end
  
end
