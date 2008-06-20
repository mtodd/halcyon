module Halcyon
  
  # Handles initializing and running the application, including:
  # * setting up the logger
  # * loading initializers
  # * loading controllers
  # All of which is done by the call to <tt>Halcyon::Application.boot</tt>.
  # 
  # The Runner is a full-fledged Rack application, and accepts calls to #call.
  # 
  # Also handles running commands form the command line.
  # 
  # Examples
  #   # start serving the current app (in .)
  #   Halcyon::Runner.run!(['start', '-p', '4647'])
  #   
  #   # load the config file and initialize the app
  #   Halcyon::Runner.new
  class Runner
    
    autoload :Commands, 'halcyon/runner/commands'
    
    # Initializes the application and application resources.
    def initialize(&block)
      Halcyon::Application.boot(&block)
      @app = Halcyon::Application.new
    end
    
    # Calls the application, which gets proxied to the dispatcher.
    #   +env+ the request environment details
    # 
    # Returns [Fixnum:status, {String:header => String:value}, [String:body]]
    def call(env)
      @app.call(env)
    end
    
    class << self
      
      # Runs commands from the CLI.
      #   +argv+ the arguments to pass to the commands
      # 
      # Returns nothing
      def run!(argv=ARGV)
        Commands.send(argv.shift, argv)
      end
      
    end
    
  end
end
