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
    
    DEFAULT_OPTIONS = {
      :root => Dir.pwd,
      :environment => 'none',
      :port => 9267,
      :host => 'localhost',
      :server => Gem.searcher.find('thin').nil? ? 'mongrel' : 'thin',
      :pid_file => '/var/run/halcyon.{server}.{app}.{port}.pid',
      :log_file => '/var/log/halcyon.{app}.log',
      :log_level => 'info',
      :log_format => proc{|s,t,p,m|"#{s} [#{t.strftime("%Y-%m-%d %H:%M:%S")}] (#{$$}) #{p} :: #{m}\n"},
      # handled internally
      :acceptable_requests => [],
      :acceptable_remotes => []
    }
    ACCEPTABLE_REQUESTS = [
      # ENV var to check, Regexp the value should match, the status code to return in case of failure, the message with the code
      ["HTTP_USER_AGENT", /JSON\/1\.1\.\d+ Compatible( \(en-US\) Halcyon\/(\d+\.\d+\.\d+) Client\/(\d+\.\d+\.\d+))?/, 406, 'Not Acceptable'],
      ["CONTENT_TYPE", /application\/json/, 415, 'Unsupported Media Type']
    ]
    ACCEPTABLE_REMOTES = ['localhost', '127.0.0.1', '0.0.0.0']
    
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
    # all requests in the format <tt>/hello/:name</tt> where the word pattern
    # is stored and transmitted as the appropriate keys in the params hash.
    # 
    # Once we've got our inputs specified, we can start to handle requests:
    # 
    #   class Greeter < Halcyon::Server::Base
    #     route do |r|
    #       r.match('/hello/:name').to(:action => 'greet')
    #       {:action => 'not_found'} # default route
    #     end
    #     def greet; {:status=>200, :body=>"Hi #{params[:name]}"}; end
    #   end
    # 
    # You will notice that we only define the method +greet+ and that it
    # returns a Hash object containing a +status+ code and +body+ content.
    # This is the most basic way to send data, but if all you're doing is
    # replying that the request was successful and you have data to return,
    # the method +ok+ (an alias of <tt>standard_response</tt>) with the +body+
    # param as its sole parameter is sufficient.
    # 
    # 
    #   def greet; ok("Hi #{params[:name]}"); end
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
    # Lastly, the use of +params+ inside the method is simply a method call
    # to a hash of the parameters gleaned from the route, such as +:name+ or
    # any other variables passed to it.
    # 
    # == The Filesystem
    # 
    # It's important to note that the +halcyon+ commandline tool expects to
    # find your server inheriting +Halcyon::Server::Base+ with the same exact
    # name as its filename, though with special rules.
    # 
    # To clarify, when your server is stored in +app_server.rb+, it expects
    # that your server's class name be +AppServer+ as it capitalizes each word
    # and removes all underscores, etc.
    # 
    # Keep this in mind when naming your class and your file, though this
    # restriction is only temporary.
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
      # == Request and Response
      # 
      # If you need access to the Request and Response, the instance variables
      # +@req+ and +@res+ will be sufficient for you.
      # 
      # If you need specific documentation for these objects, check the
      # corresponding docs in the Rack documentation.
      # 
      # == Requests and POST Data
      # 
      # Most of your requests will have all the data it needs inside of the
      # +params+ you receive for your action, but for POST and PUT requests
      # (you are being RESTful, right?) you will need to retrieve your data
      # from the method +post+. Here's how:
      # 
      #   post[:key] => "value"
      # 
      # As you can see, keys specifically are symbols and values as well. What
      # this means is that your POST data that you send to the server needs to
      # be careful to provide a flat Hash (if anything other than a Hash is
      # passed, it is packed up into a hash similar to +{:body=>data}+) or at
      # least send a complicated structure as a JSON object so that transport
      # is clean. Resurrecting the object is still on your end for POST data
      # (though this could change). Here's how you would reconstruct your
      # special hash:
      # 
      #   value = JSON.parse(post[:key])
      # 
      # That will take care of reconstructing your Hash.
      # 
      # And that is essentially all you need to worry about for retreiving your
      # POST contents. Sending POST contents should be documented well enough
      # in Halcyon::Client::Base.
      # 
      # == Logging
      # 
      # Logging can be done by logging to +@logger+ when inside the scope of
      # application instance (inside of your instance methods and modules).
      # 
      # The +@env+ instance variable has been modified to include a
      # +halcyon.logger+ property including the given logger. Use this for
      # logging if you need to step outside of the scope of the current
      # application instance (just be sure to pass @env along with you).
      def call(env)
        @time_started = Time.now
        
        # collect env information, create request and response objects, prep for dispatch
        # puts env.inspect if $debug # request information (huge)
        @env = env
        @res = Rack::Response.new
        @req = Rack::Request.new(env)
        
        # add the logger to the @env instance variable for global access if for
        # some reason the environment needs to be passed outside of the
        # instance
        @env['halcyon.logger'] = @logger
        
        # pre run hook
        before_run(Time.now - @time_started) if respond_to? :before_run
        
        # prepare route and provide it for callers
        route = Router.route(@env)
        @env['halcyon.route'] = route
        
        # dispatch
        @res.write(run(route).to_json)
        
        # post run hook
        after_run(Time.now - @time_started) if respond_to? :after_run
        
        @time_finished = Time.now - @time_started
        
        # logs access in the following format: [200] / => index (0.0029s;343.79req/s)
        req_time, req_per_sec = ((@time_finished*1e4).round.to_f/1e4), (((1.0/@time_finished)*1e2).round.to_f/1e2)
        @logger.info "[#{@res.status}] #{@env['REQUEST_URI']} => #{route[:module].to_s}#{((route[:module].nil?) ? "" : "::")}#{route[:action]} (#{req_time}s;#{req_per_sec}req/s)"
        
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
      # result in a given HTTP Response code other than 2xx, an appropriate
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
      # When in debug mode or in testing mode, the request filtering test is
      # not fired, so all requests from all User Agents and locations will
      # succeed. This is important to know if you plan on testing this specific
      # feature while in debugging or testing modes.
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
      # (or one of its inheriters) instead of handling them manually. This
      # ensures that the actual action is not run when in fact it shouldn't,
      # otherwise you could be allowing unauthenticated users privileged
      # information or allowing them to perform destructive actions.
      def run(route)
        # make sure the request meets our expectations
        acceptable_request! unless $debug || $test
        
        # pull params
        @params = route.reject{|key, val| [:action, :module].include? key}
        @params.merge!(query_params)
        
        # pre call hook
        before_call if respond_to? :before_call
        
        # handle module actions differently than non-module actions
        if route[:module].nil?
          # call action
          res = send(route[:action])
        else
          # call module action
          mod = self.dup
          mod.instance_eval(&(@@modules[route[:module].to_sym]))
          res = mod.send(route[:action])
        end
        
        # after call hook
        after_call if respond_to? :after_call
        
        @params = {}
        
        res
      rescue Halcyon::Exceptions::Base => e
        @logger.warn "#{uri} => #{e.error}"
        # handles all content error exceptions
        @res.status = e.status
        {:status => e.status, :body => e.error}
      end
      
      # Tests for acceptable requests if +$debug+ and +$test+ are not set.
      def acceptable_request!
        @config[:acceptable_requests].each do |req|
          raise Halcyon::Exceptions::Base.new(req[2], req[3]) unless @env[req[0]] =~ req[1]
        end
        raise Exceptions::Forbidden.new unless @config[:acceptable_remotes].member? @env["REMOTE_ADDR"]
      end
      
      #--
      # Initialization and setup
      #++
      
      # Called when the Handler gets started and stores the configuration
      # options used to start the server.
      # 
      # Feel free to define initialize for your app (which is only called once
      # per server instance), just be sure to call +super+.
      # 
      # == PID File
      # 
      # A PID file is created when the server is first initialized with the
      # current process ID. Where it is located depends on the default option,
      # the config file, the commandline option, and the debug status,
      # increasing in precedence in that order.
      # 
      # By default, the PID file is placed in +/var/run/+ and is named
      # +halcyon.{server}.{app}.{port}.pid+ where +{server}+ is replaced by the
      # running server, +{app}+ is the app name (suffixed with +#debug+ if
      # running in debug mode), and +{port}+ being the server port (if there
      # are multiple servers running, this helps clarify).
      # 
      # There is an option to numerically label your server  via the +{n}+
      # value, but this is deprecated and will be removed soon. Using the
      # +{port}+ option makes much more sense and creates much more meaning.
      def initialize(options = {})
        # save configuration options
        @config = DEFAULT_OPTIONS.merge(options)
        @config[:app] ||= self.class.to_s.downcase
        
        # apply name options to log_file and pid_file configs
        apply_log_and_pid_file_name_options
        
        # debug and test mode handling
        enable_debugging if $debug
        enable_testing if $test
        
        # setup logging
        setup_logging unless $debug || $test
        
        # setup request filtering
        setup_request_filters unless $debug || $test
        
        # create PID file
        @pid = File.new(@config[:pid_file].gsub('{n}', server_cluster_number), "w", 0644)
        @pid << "#{$$}\n"; @pid.close
        
        # log existence
        @logger.info "PID file created. PID is #{$$}."
        
        # call startup callback if defined
        startup if respond_to? :startup
        
        # log ready state
        @logger.info "Started. Awaiting connectivity. Listening on #{@config[:port]}..."
        
        # trap signals to die (when killed by the user) gracefully
        finalize =  Proc.new do
          @logger.info "Shutting down #{$$}."
          clean_up
          exit
        end
        # http://en.wikipedia.org/wiki/Signal_%28computing%29
        %w(INT KILL TERM QUIT HUP).each{|sig|trap(sig, finalize)}
        
        # listen for USR1 signals and toggle debugging accordingly
        trap("USR1") do
          if $debug
            disable_debugging
          else
            enable_debugging
          end
        end
      end
      
      # Closes the logger and deletes the PID file.
      def clean_up
        # don't try to clean up what's cleaned up already
        return if defined? @cleaned_up
        
        # run shutdown hook if defined
        shutdown if respond_to? :shutdown
        
        # close logger, delete PID file, flag clean state
        @logger.close
        File.delete(@pid.path) if File.exist?(@pid.path)
        @cleaned_up = true
      end
      
      # Retreives the server cluster sequence number for the PID file.
      # 
      # This is deprecated and will be removed soon, probably for the 0.4.0
      # release. Use of the +{port}+ value is much more appropriate and
      # meaningful.
      def server_cluster_number
        # if there are no +{n}+ references in the PID file name, then simply
        # return 0 as the cluster number. (This is the preferred behavior and
        # this test allows the method to fail fast. +{n}+ is deprecated and
        # will be removed before 0.4.0 is released.)
        return 0.to_s if @config[:pid_file]['{n}'].nil?
        
        # warn users that they're using a deprecated convention.
        warn "Your PID file name contains '{n}' (#{@config[:pid_file]}). This is deprecatd and will be removed by the 0.4.0 release. Use '{port}' instead."
        
        # counts the number of PID files already existing.
        server_count = Dir[@config[:pid_file].gsub('{n}','*')].length
        # since the counting starts at 0, if the file with the count exists,
        # then one of the lesser number servers isn't running, so check each
        # PID file until the one not running is found.
        # if no files exist, then 0 will be the count, which won't exist, so
        # it will be the default number.
        while File.exist?(@config[:pid_file].gsub('{n}',server_count.to_s))
          server_count -= 1
        end
        # return that number.
        server_count.to_s
      end
      
      # If the server receives a SIGUSR1 signal it will toggle debugging. This
      # method is used to setup logging and the request handling methods for
      # debugging.
      def enable_debugging
        $debug = true
        
        # set the PID file name to /tmp/ unless PID file already exists
        @config[:pid_file] = '/tmp/halcyon.{server}.{app}.{port}.pid' unless defined? @pid
        apply_log_and_pid_file_name_options # reapply for {server}, {app}, and {port} to be set
        
        # setup logger to STDOUT and log entering debugging mode
        @logger = Logger.new(STDOUT)
        @logger.progname = "#{self.class}#debug"
        @logger.level = Logger::DEBUG
        @logger.formatter = @config[:log_format]
        @logger.info "Entering debugging mode..."
      rescue Errno::EACCES
      	abort "Can't access #{@config[:pid_file]}, try 'sudo #{$0}'"
      end
      
      # This method is used to setup logging and the request handling methods
      # for debugging.
      def enable_testing
        # set the PID file name to /tmp/ unless PID file already exists
        @config[:pid_file] = '/tmp/halcyon.testing.{app}.{port}.pid' unless defined? @pid
        @config[:log_file] = '/tmp/halcyon.testing.{app}.log'
        apply_log_and_pid_file_name_options # reapply for {server}, {app}, and {port} to be set
        
        # setup logger and log entering testing mode
        @logger = Logger.new(@config[:log_file])
        @logger.progname = "#{self.class}#test"
        @logger.level = Logger::DEBUG
        @logger.formatter = @config[:log_format]
        @logger.info "Entering testing mode..."
        
        # make sure we clean up after ourselves since we're in testing mode
        at_exit {
          clean_up
          File.delete(@config[:log_file]) if File.exist?(@config[:log_file])
        }
      rescue Errno::EACCES
      	abort "Can't access #{@config[:pid_file]}, try 'sudo #{$0}'"
      end
      
      # Disables all of the affects of debugging mode and returns logging and
      # request filtering back to normal.
      # 
      # Refer to +enable_debugging+ for more information.
      def disable_debugging
        # disable logging and log leaving debugging mode
        $debug = false
        @logger.info "Leaving debugging mode."
        
        # setup normal logging
        setup_logging
        
        # reenable request filtering
        setup_request_filters
      end
      
      # Sets up logging based on the configuration options in +@config+, which
      # is set (in order of lowest to highest precedence) in the default
      # options, in the configuration file provided, on the commandline, and
      # debug mode options.
      # 
      # == Levels
      # 
      # The accepted level values are as follows:
      # 
      # * debug
      # * info
      # * warn
      # * error
      # * fatal
      # * unknown
      # 
      # These are the exact way you can refer to the logger level you'd like to
      # log at from all points of option specification (listed above in order
      # of ascending precedence).
      # 
      # If a bogus value is entered, a warning will be issued and the value
      # will be defaulted to 'debug'. (So don't mess up.)
      def setup_logging
        # get the logging level based on the name supplied
        level = {
          'debug' => Logger::DEBUG,
          'info'  => Logger::INFO,
          'warn'  => Logger::WARN,
          'error' => Logger::ERROR,
          'fatal' => Logger::FATAL,
          'unknown' => Logger::UNKNOWN # wtf?
        }[@config[:log_level]]
        if level.nil?
          warn "Logging level specified not acceptable. Defaulting to 'debug'. Check the documentation for the acceptable values."
          @config[:log_level] = 'debug'
          level = Logger::DEBUG
        end
        
        # setup the logger
        @logger = Logger.new(@config[:log_file])
        @logger.progname = self.class
        @logger.level = level
        @logger.formatter = @config[:log_format]
      rescue Errno::EACCES
      	abort "Can't access #{@config[:log_file]}, try 'sudo #{$0}'"
      end
      
      # Sets up request filters based on User-Agent, Content-Type, and Remote
      # IP/address values.
      # 
      # Extracted from +initialize+ to reduce repetition.
      def setup_request_filters
        @config[:acceptable_requests] = ACCEPTABLE_REQUESTS
        @config[:acceptable_remotes] = ACCEPTABLE_REMOTES
      end
      
      # Searches through the PID file name and the Log file name stored in the
      # +@config+ variable for +{server}+, +{app}+, and +{port}+ values and
      # sets them accordingly.
      def apply_log_and_pid_file_name_options
        # DEFAULT :pid_file => '/var/run/halcyon.{server}.{app}.{port}.pid',
        @config[:pid_file].gsub!('{server}', @config[:server])
        @config[:pid_file].gsub!('{port}', @config[:port].to_s)
        @config[:pid_file].gsub!('{app}', File.basename(@config[:app]))
        # DEFAULT :log_file => '/var/log/halcyon.{app}.log',
        @config[:log_file].gsub!('{server}', @config[:server])
        @config[:log_file].gsub!('{port}', @config[:port].to_s)
        @config[:log_file].gsub!('{app}', File.basename(@config[:app]))
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
      
      # Returns the params of the current request, set in the +run+ method.
      def params
        @params
      end
      
      # Returns the params following the ? in a given URL as a hash
      def query_params
        @env['QUERY_STRING'].split(/&/).inject({}){|h,kp| k,v = kp.split(/=/); h[k] = v; h}.symbolize_keys!
      end
      
      # Returns the URI requested
      def uri
        # special parsing is done to remove the protocol, host, and port that
        # some Handlers leave in there. (Fixes inconsistencies.)
        URI.parse(@env['REQUEST_URI'] || @env['PATH_INFO']).path
      end
      
      # Returns the Request Method as a lowercase symbol.
      # 
      # One useful situation for this method would be similar to this:
      # 
      #   case method
      #   when :get
      #     # perform reading operations
      #   when :post
      #     # perform updating operations
      #   when :put
      #     # perform creating operations
      #   when :delete
      #     # perform deleting options
      #   end
      # 
      # It can also be used in many other cases, like throwing an exception if
      # an action is called with an unexpected method.
      def method
        @env['REQUEST_METHOD'].downcase.to_sym
      end
      
      # Returns the POST data hash, making the keys symbols first.
      # 
      # Use like <tt>post[:post_param]</tt>.
      def post
        @req.POST.symbolize_keys!
      end
      
      # Returns the GET data hash, making the keys symbols first.
      # 
      # Use like <tt>get[:get_param]</tt>.
      def get
        @req.GET.symbolize_keys!
      end
      
    end
    
  end
end
