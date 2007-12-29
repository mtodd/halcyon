#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

#--
# dependencies
#++

%w(logger json).each {|dep|require dep}

#--
# module
#++

module Halcyon
  class Server
    
    DEFAULT_OPTIONS = {}
    ACCEPTABLE_REQUESTS = [
      ["HTTP_USER_AGENT", /JSON\/1\.1\.\d+ Compatible( \(en-US\) Halcyon\/(\d+\.\d+\.\d+) Client\/(\d+\.\d+\.\d+))?/, 406, 'Not Acceptable'],
      ["CONTENT_TYPE", /application\/json/, 415, 'Unsupported Media Type']
    ]
    ACCEPTABLE_REMOTES = ['localhost', '127.0.0.1']
    
    # = Building Halcyon Server Apps
    # 
    # Halcyon apps are actually little servers running on top of Rack instances
    # which affords a great deal of simplicity and quickness to both design and
    # performance.
    # 
    # Building a Halcyon app consists of defining routes to map all requests
    # against in order to designate what functionality handles what specific
    # requests, the actual actions (and modules) to actually perform these
    # requests, and any extensions or configurations you may need or want for
    # your individual needs.
    # 
    # == Inheriting from Halcyon::Server::Base
    # 
    # To begin with, an application would be started by simply defining a class
    # that inherits from Halcyon::Server::Base.
    # 
    #   class Greeter < Halcyon::Server::Base
    #   end
    # 
    # Once this task has been completed, routes can be defined.
    # 
    #   class Greeter < Halcyon::Server::Base
    #     route do |r|
    #       r.match('/hello/:name').to(:action => 'greet')
    #       {:action => 'not_found'} # default route
    #     end
    #   end
    # 
    # Two routes are (effectively) defined here, the first being to watch for
    # all requests in the format +/hello/:name+ where the word pattern is
    # stored and transmitted as the appropriate keys in the params hash.
    # 
    # Once we've got our inputs specified, we can start to handle requests:
    # 
    #   class Greeter < Halcyon::Server::Base
    #     route do |r|
    #       r.match('/hello/:name').to(:action => 'greet')
    #       {:action => 'not_found'} # default route
    #     end
    #     def greet(p); {:status=>200, :body=>"Hi #{p[:name]}"}; end
    #   end
    # 
    # You will notice that we only define the method +greet+ and that it
    # returns a Hash object containing a +status+ code and +body+ content.
    # This is the most basic way to send data, but if all you're doing is
    # replying that the request was successful and you have data to return,
    # the method +ok+ (an alias of +standard_response+) with the +body+ param
    # as its sole parameter is sufficient.
    # 
    # 
    #   def greet(p); ok("Hi #{p[:name]}"); end
    # 
    # You'll also notice that there's no method called +not_found+; this is
    # because it is already defined and behaves almost exactly like the +ok+
    # method. We could certainly overwrite +not_found+, but at this point it
    # is not necessary.
    # 
    # You should also realize that the second route is not defined. This is
    # classified as the default route, the route to follow in the event that no
    # route actually matches, so it doesn't need any of the extra path to match
    # against.
    # 
    # == The Filesystem
    # 
    # It's important to note that the +halcyon+ commandline tool expects the to
    # find your server inheriting +Halcyon::Server::Base+ with the same exact
    # name as its filename, though with special rules.
    # 
    # To clarify, when your server is stored in +app_server.rb+, it expects
    # that your server's class name be +AppServer+ as it capitalizes each word
    # and removes all underscores, etc.
    # 
    # Keep this in mind when naming your class and your file.
    # 
    # NOTE: This really isn't a necessary step if you write your own deployment
    # script instead of using the +halcyon+ commandline tool (as it is simply
    # a convenience tool). In such, feel free to name your server however you
    # prefer and the file likewise.
    # 
    # == Running Your Server On Your Own
    # 
    # If you're wanting to run your server without the help of the +halcyon+
    # commandline tool, you will simply need to initialize the server as you
    # pass it to the Rack handler of choice along with any configuration
    # options you desire.
    # 
    # The following should be enough:
    # 
    #   Rack::Handler::Mongrel.run YourAppName.new(options), :Port => 9267
    # 
    # Of course Halcyon already handles most of your dependencies for you, so
    # don't worry about requiring Rack, et al. And again, the options are not
    # mandatory as the default options are certainly acceptable.
    # 
    # NOTE: If you want to provide debugging information, just set +$debug+ to
    # +true+ and you should receive all the debugging information available.
    class Base
      
      #--
      # Request Handling
      #++
      
      # = Handling Calls
      # 
      # Receives the request, handles the route matching, runs the approriate
      # action based on the route determined (or defaulted to) and finishes by
      # responding to the client with the content returned.
      # 
      # == Response and Output
      # 
      # Halcyon responds in purely JSON format (except perhaps on sever server
      # malfunctions that aren't caught or intended; read: bugs).
      # 
      # The standard response is simply a JSON-encoded hash following this
      # format:
      # 
      #   {:status => http_status_code, :body => response_body}
      # 
      # Response body can be any object desired (as long as there is a
      # +to_json+ method for it, which includes most core classes), usually
      # containing a nested hash with appropriate data.
      # 
      # DO NOT try to call +to_json+ on the +body+ contents as this will cause
      # errors when trying to parse JSON.
      # 
      # == Requests and POST Data
      # 
      # Most of your requests will have all the data it needs inside of the
      # +params+ you receive for your action, but for POST and PUT requests
      # (you are being RESTful, right?) you will need to retrieve your data
      # from the +POST+ property of the +@req+ request. Here's how:
      # 
      #   @req.POST['key'] => "value"
      # 
      # As you can see, keys specifically are strings and values as well. What
      # this means is that your POST data that you send to the server needs to
      # be careful to provide a flat Hash (if anything other than a Hash is
      # passed, it is packed up into a hash similar to +{:body=>data}+) or at
      # least send a complicated structure as a JSON object so that transport
      # is clean. Resurrecting the object is still on your end for POST data
      # (though this could change). Here's how you would reconstruct your
      # special hash:
      # 
      #   value = JSON.parse(@req.POST['key'])
      # 
      # That will take care of reconstructing your Hash.
      # 
      # And that is essentially all you need to worry about for retreiving your
      # POST contents. Sending POST contents should be documented well enough
      # in Halcyon::Client::Base.
      def call(env)
        @start_time = Time.now if $debug
        
        # collect env information, create request and response objects, prep for dispatch
        # puts env.inspect if $debug # request information (huge)
        @env = env
        @res = Rack::Response.new
        @req = Rack::Request.new(env)
        
        ACCEPTABLE_REMOTES.replace([@env["REMOTE_ADDR"]]) if $debug
        
        # pre run hook
        before_run(Time.now - @start_time) if respond_to? :before_run
        
        # dispatch
        @res.write(run(Router.route(env)).to_json)
        
        # post run hook
        after_run(Time.now - @start_time) if respond_to? :after_run
        
        puts "Served #{env['REQUEST_URI']} in #{(Time.now - @start_time)}" if $debug
        
        # finish request
        @res.finish
      end
      
      # = Dispatching Requests
      # 
      # Dispatches the routed request, handling module resolution and pulling
      # all of the param values together for the action. This action is called
      # by +call+ and should be transparent to your server app.
      # 
      # One of the design elements of this method is that it rescues all
      # Halcon-specific exceptions (defined innside of ::Base::Exceptions) so
      # that a proper JSON response may be rendered by +call+.
      # 
      # With this in mind, it is preferred that, for any errors that should
      # result in a given HTTP Response code other than 200, an appropriate
      # exception should be thrown which is then handled by this method's
      # rescue clause.
      # 
      # Refer to the Exceptions module to see a list of available Exceptions.
      # 
      # == Acceptable Requests
      # 
      # Halcyon is a very picky server when dealing with requests, requiring
      # that clients match a given remote location, accepting JSON responses,
      # and matching a certain User-Agent profile. Unless running in debug
      # mode, Halcyon will reject all requests with a 403 Forbidden response
      # if these requirements are not met.
      # 
      # This means, while in development and testing, the debug flag must be
      # enabled if you intend to perform initial tests through the browser.
      # 
      # These restrictions may appear to be arbitrary, but it is simply a
      # measure to prevent a live server running in production mode from being
      # assaulted by unacceptable clients which keeps the server performing
      # actual functions without concerning itself with non-acceptable clients.
      # 
      # The requirements are defined by the Halcyon::Server constants:
      # * +ACCEPTABLE_REQUESTS+:    defines the necessary User-Agent and Accept
      #                             headers the client must provide.
      # * ACCEPTABLE_REMOTES:       defines the acceptable remote origins of
      #                             any request. This is primarily limited to
      #                             only local requests, but can be changed.
      # 
      # Halcyon servers are intended to be run behind other applications and
      # primarily only speaking with other apps on the same machine, though
      # your specific requirements may differ and change that.
      # 
      # == Hooks, Callbacks, and Authentication
      # 
      # There is no Authentication mechanism built in to Halcyon (for the time
      # being), but there are hooks and callbacks for you to be able to ensure
      # that requests are authenticated, etc.
      # 
      # In order to set up a callback, simply define one of the following
      # methods in your app's base class:
      # * before_run
      # * before_action
      # * after_action
      # * after_run
      # 
      # This is the exact order in which the callbacks are performed if
      # defined. Make use of these methods to monitor incoming and outgoing
      # requests.
      # 
      # It is preferred for these methods to throw Exceptions::Base exceptions
      # (or one of its inheriters) instead of handling them manually.
      def run(route)
        # make sure the request meets our expectations
        ACCEPTABLE_REQUESTS.each do |req|
          raise Exceptions::Base.new(req[2], req[3]) unless @env[req[0]] =~ req[1]
        end
        raise Exceptions::Forbidden.new unless ACCEPTABLE_REMOTES.member? @env["REMOTE_ADDR"]
        
        # pull params
        params = route.reject{|key, val| [:action, :module].include? key}
        params.merge!(query_params)
        
        # pre call hook
        before_call(route, params) if respond_to? :before_call
        
        # handle module actions differently than non-module actions
        if route[:module].nil?
          # call action
          res = send(route[:action], params)
        else
          # call module action
          mod = self.dup
          mod.instance_eval(&(@@modules[route[:module].to_sym]))
          res = mod.send(route[:action], params)
        end
        
        # after call hook
        after_call if respond_to? :after_call
        
        res
      rescue Exceptions::Base => e
        # puts @env.inspect if $debug
        # handles all content error exceptions
        @res.status = e.status
        {:status => e.status, :body => e.error}
      end
      
      #--
      # Initialization and setup
      #++
      
      # Called when the Handler gets started and stores the configuration
      # options used to start the server.
      def initialize(options = {})
        # debug mode handling
        if $debug
          puts "Entering debugging mode..."
          @logger = Logger.new(STDOUT)
          ACCEPTABLE_REQUESTS.replace([
            ["HTTP_USER_AGENT", /.*/, 406, 'Not Acceptable'],
            ["HTTP_USER_AGENT", /.*/, 415, 'Unsupported Media Type'] # content type isn't set when navigating via browser
          ])
        end
        
        # save configuration options
        @config = DEFAULT_OPTIONS.merge(options)
        
        # setup logging
        @logger ||= Logger.new(@config[:log_file])
        
        puts "Started. Awaiting input. Listening on #{@config[:port]}..." if $debug
      end
      
      # = Routing
      # 
      # Halcyon expects its apps to have routes set up inside of the base class
      # (the class that inherits from Halcyon::Server::Base). Routes are
      # defined identically to Merb's routes (since Halcyon Router inherits all
      # its functionality directly from the Merb Router).
      # 
      # == Usage
      # 
      # A sample Halcyon application defining and handling Routes follows:
      # 
      #   class Simple < Halcyon::Server::Base
      #     route do |r|
      #       r.match('/user/show/:id').to(:module => 'user', :action => 'show')
      #       r.match('/hello/:name').to(:action => 'greet')
      #       r.match('/').to(:action => 'index')
      #       {:action => 'not_found'} # default route
      #     end
      #     user do
      #       def show(p); ok(p[:id]); end
      #     end
      #     def greet(p); ok("Hi #{p[:name]}"); end
      #     def index(p); ok("..."); end
      #     def not_found(p); super; end
      #   end
      # 
      # In this example we define numerous routes for actions and even an
      # action in the 'user' module as well as handling the event that no route
      # was matched (thereby passing to not_found).
      # 
      # == Modules
      # 
      # A module is simply a named block that whose methods get executed as if
      # they were in Base but without conflicting any methods with them, very
      # similar to module in Ruby. All that is required to define a module is
      # something like this:
      # 
      #   admin do
      #     def users; ok(...); end
      #   end
      # 
      # This just needs to add one directive when defining what a given route
      # maps to, such as:
      # 
      #   route do |r|
      #     r.map('/admin/users').to(:module => 'admin', :action => 'users')
      #   end
      # 
      # or, alternatively, you can just map to:
      # 
      #   r.map('/:module/:action').to()
      # 
      # though it may be better to just explicitly state the module (for
      # resolving cleanly when someone starts entering garbage that matches
      # incorrectly).
      # 
      # == More Help
      # 
      # In addition to this, you may also find some of the documentation for
      # the Router class helpful. However, since the Router is pulled directly
      # from Merb, you really should look at the documentation for Merb. You
      # can find the documentation on Merb's website at: http://merbivore.com/
      def self.route
        if block_given?
          Router.prepare do |router|
            Router.default_to yield(router) || {:action => 'not_found'}
          end
        else
          abort "Halcyon::Server::Base.route expects a block to define routes."
        end
      end
      
      # Registers modules internally. (This is designed in a way to prevent
      # method naming collisions inside and outside of modules.)
      def self.method_missing(name, *params, &proc)
        @@modules ||= {}
        @@modules[name] = proc
      end
      
      #--
      # Properties and shortcuts
      #++
      
      # Takes +msg+ as parameter and formats it into the standard response type
      # expected by an action's caller. This format is as follows:
      # 
      #   {:status => http_status_code, :body => json_encoded_body}
      # 
      # The methods +standard_response+,  +success+, and +ok+ all handle any
      # textual message and puts it in the body field, defaulting to the 200
      # response class status code.
      def standard_response(body = 'OK')
        {:status => 200, :body => body}
      end
      alias_method :success, :standard_response
      alias_method :ok, :standard_response
      
      # Similar to the +standard_response+ method, takes input and responds
      # accordingly, which is by raising an exception (which handles formatting
      # the response in the normal response hash).
      def not_found(body = 'Not Found')
        body = 'Not Found' if body.is_a?(Hash) && body.empty?
        raise Exceptions::NotFound.new(404, body)
      end
      
      # Returns the params following the ? in a given URL as a hash
      def query_params
        @env['QUERY_STRING'].split(/&/).inject({}){|h,kp| k,v = kp.split(/=/); h[k] = v; h}
      end
      
      # Returns the URI requested
      def uri
        @env['REQUEST_URI']
      end
      
      # Returns the Request Method as a lowercase symbol
      def method
        @env['REQUEST_METHOD'].downcase.to_sym
      end
      
    end
    
  end
end
