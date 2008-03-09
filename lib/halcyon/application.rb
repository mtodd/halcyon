module Halcyon
  
  # The core of Halcyon on the server side is the Halcyon::Application class
  # which handles dispatching requests and responding with appropriate messages
  # to the client (which can be specified).
  class Application
    include Exceptions
    
    autoload :Router, 'halcyon/application/router'
    
    DEFAULT_OPTIONS = {
      :root => Dir.pwd,
      :logger => Logger.new(STDOUT),
      :log_level => 'info',
      :log_format => proc{|s,t,p,m|"#{s} [#{t.strftime("%Y-%m-%d %H:%M:%S")}] (#{$$}) #{p} :: #{m}\n"},
      :allow_from => :all
    }
    
    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge options
      
      @logger = @options[:logger]
      @logger.progname = self.class.to_s
      @logger.formatter = proc{|s,t,p,m|"#{s} [#{t.strftime("%Y-%m-%d %H:%M:%S")}] (#{$$}) #{p} :: #{m}\n"}
      @logger.info "Starting up..."
      
      startup if respond_to? :startup
      
      @logger.info "Started. PID is #{$$}"
      
      at_exit do
        @logger.info "Shutting down #{$$}."
        shutdown if respond_to? :shutdown
        @logger.info "Done."
      end
      
      # clean after ourselves and get prepared to start serving things
      GC.start
    end
    
    def call(env)
      timing = {:started => Time.now}
      
      @env = env
      @request = Rack::Request.new(@env)
      @response = Rack::Response.new
      
      @response['Content-Type'] = "application/json" # "text/plain" for debugging maybe?
      @response['User-Agent'] = "JSON/#{JSON::VERSION} Compatible (en-US) Halcyon::Application/#{Halcyon.version}"
      
      begin
        acceptable_request!
        
        @env['halcyon.route'] = Router.route(@env)
        response = _dispatch(@env['halcyon.route'])
      rescue Exceptions::Base => e
        response = {:status => e.status, :body => e.body}
        @logger.info e.message
      rescue Exception => e
        response = {:status => 500, :body => 'Internal Server Error'}
        @logger.error "#{e.message}\n\t" << e.backtrace.join("\n\t")
      end
      
      @response.status = response[:status]
      @response.write response.to_json
      
      timing[:finished] = Time.now
      timing[:total] = (((timing[:finished] - timing[:started])*1e4).round.to_f/1e4)
      timing[:per_sec] = (((1.0/(timing[:total]))*1e2).round.to_f/1e2)
      @logger.info "[#{@response.status}] #{URI.parse(env['REQUEST_URI'] || env['PATH_INFO']).path} (#{timing[:total]}s;#{timing[:per_sec]}req/s)"
      @logger << "DEBUG Params: #{@params.inspect}\n\n"
      
      @response.finish
    end
    
    def _dispatch(route)
      @params = route.reject{|key, val| [:action, :module].include? key}
      @params.merge!(query_params)
      
      # make sure that the right module/action is called based on the route
      case route[:module]
      when NilClass
        # not a part of a module
        send(route[:action].to_sym)
      when Symbol
        # module name specified
        self.class.class_eval { include const_get(route[:module]) }
        self.class.const_get(route[:module]).instance_method(route[:action].to_sym).bind(self).call
        # TODO: figure out how to do this... the bound object has to be kind_of? the module where it was plucked from
      when String
        # pulled from URL, so camelize (from merb/core_ext) and symbolize first
        _dispatch(route.merge(:module => route[:module].camelize.to_sym))
      end
    end
    
    # Filters unacceptable requests depending on the configuration of the
    # <tt>:allow_from</tt> option.
    # Acceptable values include:
    # 
    #   <tt>:all</tt>:: allow every request to go through
    #   <tt>:halcyon_clients</tt>:: only allow Halcyon clients
    #   <tt>:local</tt>:: do not allow for requests from an outside host
    def acceptable_request!
      case @options[:allow_from].to_sym
      when :all
        # allow every request to go through
      when :halcyon_clients
        # only allow Halcyon clients
        raise Exception::Forbidden.new unless @env['USER_AGENT'] =~ /JSON\/1\.1\.\d+ Compatible \(en-US\) Halcyon::Client\(\d+\.\d+\.\d+\)/
      when :local
        # do not allow for requests from an outside host
        raise Exceptions::Forbidden.new unless ['localhost', '127.0.0.1', '0.0.0.0'].member? @env["REMOTE_ADDR"]
      else
        warn "Unrecognized allow_from configuration value (#{@config[:allow_from].to_s}); use all, halcyon_clients, or local."
      end
    end
    
    def self.route
      if block_given?
        Router.prepare do |router|
          Router.default_to yield(router) || {:action => 'not_found'}
        end
      end
    end
    
    def params
      @params.to_mash
    end
    
    def post
      @request.POST.to_mash
    end
    
    def get
      @request.GET.to_mash
    end
    
    def query_params
      @env['QUERY_STRING'].split(/&/).inject({}){|h,kp| k,v = kp.split(/=/); h[k] = v; h}.to_mash
    end
    
    def uri
      # special parsing is done to remove the protocol, host, and port that
      # some Handlers leave in there. (Fixes inconsistencies.)
      URI.parse(@env['REQUEST_URI'] || @env['PATH_INFO']).path
    end
    
    def method
      @env['REQUEST_METHOD'].downcase.to_sym
    end
    
    def ok(msg='OK')
      {:status => 200, :body => msg}
    end
    alias_method :success, :ok
    
    def not_found(msg='Not Found')
      {:status => 404, :body => msg}
    end
    
  end
  
end
