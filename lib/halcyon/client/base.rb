#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

#--
# dependencies
#++

%w(net/http uri json).each {|dep|require dep}

#--
# module
#++

module Halcyon
  class Client
    
    DEFAULT_OPTIONS = {}
    USER_AGENT = "JSON/#{JSON::VERSION} Compatible (en-US) Halcyon/#{Halcyon.version} Client/#{Halcyon::Client.version}"
    CONTENT_TYPE = 'application/json'
    
    # = Building Custom Clients
    # 
    # Once your Halcyon JSON Server App starts to take shape, it may be useful
    # to begin to write tests on expected functionality, and then to implement
    # API calls with a designated Client lib for your Ruby or Rails apps, etc.
    # The Base class provides a standard implementation and several options for
    # wrapping up functionality of your app from the server side into the
    # client side so that you may begin to use response data.
    # 
    # == Creating Your Client
    # 
    # Creating a simple client can be as simple as this:
    # 
    #   class Simple < Halcyon::Client::Base
    #     def greet(name)
    #       get("/hello/#{name}")
    #     end
    #   end
    # 
    # The only thing simply may be actually using the Simple client you just
    # created.
    # 
    # But to actually get in and use the library, one has to take full
    # advantage of the HTTP request methods, +get+, +post+, +put+, and
    # +delete+. These methods simply return the JSON-parsed data from the
    # server, effectively returning a hash with two key values, +status+ which
    # contains the HTTP status code, and +body+ which contains the body of the
    # content returned which can be any number of objects, including, but not
    # limited to Hash, Array, Numeric, Nil, Boolean, String, etc.
    # 
    # You are not limited to what your methods can call: they are arbitrarily
    # and solely up to your whims and needs. It is simply a matter of good
    # design and performance when it comes to structuring and implementing
    # client actions which can be complex or simple series of requests to the
    # server.
    # 
    # == Acceptable Clients
    # 
    # The Halcyon Server is intended to be very picky with whom it will speak
    # to, so it requires that we specifically mention that we speak only
    # "application/html", that we're "JSON/1.1.1 Compatible", and that we're
    # local to the server itself (in process, anyways). This ensures that it
    # has to deal with as little noise as possible and focus it's attention on
    # performing our requests.
    # 
    # This shouldn't affect usage when working with the Client or in production
    # but might if you're trying to check things in your browser. Just make
    # certain that the debug option is turned on (-d for the +halcyon+ command)
    # when you start the server so that it knows to be a little more lenient
    # about to whom it speaks.
    class Base
      
      #--
      # Initialization and setup
      #++
      
      # = Connecting to the Server
      # 
      # Creates a new Client object to allow for requests and responses from
      # the specified server.
      # 
      # The +uri+ param contains the URL to the actual server, and should be in
      # the format: "http://localhost:3801" or "http://app.domain.com:3401/"
      # 
      # == Server Connections
      # 
      # Connecting only occurs at the actual event that a request is performed,
      # so there is no need to worry about closing connections or managing
      # connections in general other than good object housecleaning. (Be nice
      # to your Garbage Collector.)
      # 
      # == Usage
      # 
      # You can either provide a block to perform all of your requests and
      # processing inside of or you can simply accept the object in response
      # and call your request methods off of the returned object.
      # 
      # Alternatively, you could do both.
      # 
      # An example of creating and using a Simple client:
      # 
      #   class Simple < Halcyon::Client::Base
      #     def greet(name)
      #       get("/hello/#{name}")
      #     end
      #   end
      #   Simple.new('http://localhost:3801') do |s|
      #     puts s.greet("Johnny").inspect
      #   end
      # 
      # This should effectively call +inspect+ on a response hash similar to
      # this:
      # 
      #   {:status => 200, :body => 'Hello Johnny'}
      # 
      # Alternatively, you could perform the same with the following:
      # 
      #   s = Simple.new('http://localhost:3801')
      #   puts s.greet("Johnny").inspect
      # 
      # This should generate the exact same outcome as the previous example,
      # except that it is not executed in a block.
      # 
      # The differences are purely semantic and of personal taste.
      def initialize(uri)
        @uri = URI.parse(uri)
        if block_given?
          yield self
        end
      end
      
      #--
      # Reverse Routing
      #++
      
      # = Reverse Routing
      # 
      # The concept of writing our Routes in our Client is to be able to
      # automatically generate the appropriate URL based on the hash given
      # and where it was called from. This makes writing actions in Clients
      # go from something like this:
      # 
      #   def greet(name)
      #     get("/hello/#{name}")
      #   end
      # 
      # to this:
      # 
      #   def greet(name)
      #     get(url_for(__method__, :name))
      #   end
      # 
      # This doesn't immediately seem to be beneficial, but it is better for
      # automating URL generating, taking out the hardcoding, and has room to
      # to improve in the future.
      def url_for(action, params = {})
       Halcyon::Client::Router.route(action, params)
      end
      
      # Sets up routing for creating preparing +url_for+ URLs. See the
      # +url_for+ method documentation and the Halcyon::Client::Router docs.
      def self.route
        if block_given?
          Halcyon::Client::Router.prepare do |r|
            Halcyon::Client::Router.default_to yield(r)
          end
        else
          warn "Routes should be defined in a block."
        end
      end
      
      #--
      # Request Handling
      #++
      
      # Performs a GET request on the URI specified.
      def get(uri, headers={})
        req = Net::HTTP::Get.new(uri)
        request(req, headers)
      end
      
      # Performs a POST request on the URI specified.
      def post(uri, data, headers={})
        req = Net::HTTP::Post.new(uri)
        req.body = format_body(data)
        request(req, headers)
      end
      
      # Performs a DELETE request on the URI specified.
      def delete(uri, headers={})
        req = Net::HTTP::Delete.new(uri)
        request(req, headers)
      end
      
      # Performs a PUT request on the URI specified.
      def put(uri, data, headers={})
        req = Net::HTTP::Put.new(uri)
        req.body = format_body(data)
        request(req, headers)
      end
      
    private
      
      # Performs an arbitrary HTTP request, receive the response, parse it with
      # JSON, and return it to the caller. This is a private method because the
      # user/developer should be quite satisfied with the +get+, +post+, +put+,
      # and +delete+ methods.
      # 
      # == Request Failures
      # 
      # If the server responds with any kind of failure (anything with a status
      # that isn't 200), Halcyon will in turn raise the respective exception
      # (defined in Halcyon::Exceptions) which all inherit from
      # +Halcyon::Exceptions::Base+. It is up to the client to handle these
      # exceptions specifically.
      def request(req, headers={})
        # define essential headers for Halcyon::Server's picky requirements
        req["Content-Type"] = CONTENT_TYPE
        req["User-Agent"] = USER_AGENT
        
        # apply provided headers
        headers.each do |pair|
          header, value = pair
          req[header] = value
        end
        
        # provide hook for modifying the headers
        req = headers(req) if respond_to? :headers
        
        # prepare and send HTTP request
        res = Net::HTTP.start(@uri.host, @uri.port) {|http|http.request(req)}
        
        # parse response
        body = JSON.parse(res.body)
        body.symbolize_keys! if body.respond_to? :symbolize_keys!
        
        # handle non-successes
        raise Halcyon::Client::Base::Exceptions.lookup(body[:status]).new unless res.kind_of? Net::HTTPSuccess
        
        # return response
        body
      rescue Halcyon::Exceptions::Base => e
        # log exception if logger is in place
        raise
      end
      
      # Formats the data of a POST or PUT request (the body) into an acceptable
      # format according to Net::HTTP for sending through as a Hash.
      def format_body(data)
        data = {:body => data} unless data.is_a? Hash
        data.map{|key,value|"&#{key}=#{value}&"}.join
      end
      
    end
    
  end
end
