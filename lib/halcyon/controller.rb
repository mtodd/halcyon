module Halcyon
  
  # The base controller providing all of the methods any controller will need.
  class Controller
    include Exceptions
    
    attr_accessor :env, :request
    
    def initialize(env)
      @env = env
      @request = Rack::Request.new(@env)
    end
    
    class << self
      
      def logger
        Halcyon.logger
      end
      
      def before method, &proc
        raise NotImplemented.new
      end
      def after method, &proc
        raise NotImplemented.new
      end
      
    end
    
    def params
      self.request.params.to_mash
    end
    
    def post
      self.request.POST.to_mash
    end
    
    def get
      self.request.GET.to_mash
    end
    
    def query_params
      Rack::Utils.parse_query(self.env['QUERY_STRING']).to_mash
    end
    
    def uri
      # special parsing is done to remove the protocol, host, and port that
      # some Handlers leave in there. (Fixes inconsistencies.)
      URI.parse(self.env['REQUEST_URI'] || self.env['PATH_INFO']).path
    end
    
    def method
      self.env['REQUEST_METHOD'].downcase.to_sym
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
