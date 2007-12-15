#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

#--
# dependencies
#++

%w(logger).each {|dep|require dep}

#--
# module
#++

module Halcyon
  class Server
    
    DEFAULT_OPTIONS = {}
    ACCEPTABLE_REQUESTS = [
      ["HTTP_USER_AGENT", /JSON\/1\.1\.1 Compatible( \(en-US\) Halcyon\/(\d+\.\d+\.\d+) Client\/(\d+\.\d+\.\d+))?/, 406, 'Not Acceptable'],
      ["HTTP_ACCEPT", /application\/json/, 415, 'Unsupported Media Type']
    ]
    ACCEPTABLE_REMOTES = ['localhost', '127.0.0.1']
    
    # Server tries to comply with appropriate HTTP response codes, as found at
    # <http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html>. However, all
    # responses are JSON encoded as the server expects a JSON parser on the
    # client side since the server should not be processing requests directly
    # through the browser. The server expects the User-Agent to be one of:
    # +"User-Agent" => "JSON/1.1.1 Compatible (en-US) Halcyon/0.0.12 Client/0.0.1"+
    # +"User-Agent" => "JSON/1.1.1 Compatible"+
    # The server also expects to accept application/json and be originated
    # from the local host (though this can be overridden).
    class Base
      
      #--
      # Request Handling
      #++
      
      # receive request
      def call(env)
        # collect env information, create request and response objects, prep for dispatch
        # puts env.inspect if $debug # request information (huge)
        @env = env
        @res = Rack::Response.new
        @req = Rack::Request.new(env)
        
        ACCEPTABLE_REMOTES.replace([@env["REMOTE_ADDR"]]) if $debug
        
        # dispatch
        @res.write(run(Router.route(env)).to_json)
        
        # finish request
        @res.finish
      end
      
      # dispatch request
      def run(path)
        # make sure the request meets our expectations
        ACCEPTABLE_REQUESTS.each do |req|
          raise Server::Exception.new(req[2], req[3]) unless @env[req[0]] =~ req[1]
        end
        raise Server::Exception.new(403, 'Forbidden') unless ACCEPTABLE_REMOTES.member? @env["REMOTE_ADDR"]
        
        # pull params
        params = path.reject{|key, val| [:action, :module].include? key}
        params.merge!(query_params)
        
        # initiate action processing
        send(path[:action], params)
      rescue Halcyon::Server::Exception => e
        # handles all content error exceptions
        # puts "ERROR; ORIGIN: #{@env["REMOTE_ADDR"]} | #{@env["HTTP_ACCEPT"]} | #{@env["HTTP_USER_AGENT"]}" if $debug
        @res.status = e.status
        {:status => e.status, :body => e.error}
      end
      
      # standard successful response
      def standard_response(body = 'OK')
        {:status => 200, :body => body}
      end
      
      def not_found
        raise Server::Exception.new(404, 'Not Found')
      end
      
      #--
      # Initialization and setup
      #++
      
      # setup configuration options, etc
      def initialize(options = {})
        # debuf mode handling
        if $debug
          puts "Entering debugging mode..."
          @logger = Logger.new(STDOUT)
          ACCEPTABLE_REQUESTS.replace([
            ["HTTP_USER_AGENT", /.*/, 406, 'Not Acceptable'],
            ["HTTP_ACCEPT", /.*/, 415, 'Unsupported Media Type']
          ])
        end
        
        # save configuration options
        @config = DEFAULT_OPTIONS.merge(options)
        
        # setup logging
        @logger ||= Logger.new(@config[:log_file])
        
        puts "Started. Awaiting input. Listening on #{@config[:port]}..." if $debug
      end
      
      # setup routing
      def self.route
        if block_given?
          Router.prepare do |router|
            Router.default_to yield(router)
          end
        else
          warn "Halcyon::Server::Base.route expects a block to define routes."
        end
      end
      
      #--
      # Properties
      #++
      
      def query_params
        @env['QUERY_STRING'].split(/&/).inject({}){|h,kp| k,v = kp.split(/=/); h[k] = v; h}
      end
      
      def uri
        #
      end
      
      def method
        #
      end
      
    end
    
    #--
    # Exception classes
    #++
    
    class Exception < Exception #:nodoc:
      attr_accessor :status, :error
      def initialize(status, error)
        @status = status
        @error = error
      end
    end
    
  end
end
