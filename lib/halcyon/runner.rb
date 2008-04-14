module Halcyon
  
  # Handles initializing and running the application, including:
  # * setting up the logger
  # * loading initializers
  # * loading controllers
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
  #   Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
  #   Halcyon::Runner.new
  class Runner
    
    autoload :Commands, 'halcyon/runner/commands'
    
    class << self
      
      # Runs commands from the CLI.
      #   +argv+ the arguments to pass to the commands
      # 
      # Returns nothing
      def run!(argv=ARGV)
        Commands.send(argv.shift, argv)
      end
      
      # Returns the path to the configuration file specified, defaulting
      # to the path for the <tt>config.yml</tt> file.
      #   +file+ the name of the config file path (without the <tt>.yml</tt>
      #   extension)
      def config_path(file = "config")
        Halcyon.root/'config'/"#{file}.yml"
      end
      
    end
    
    # Initializes the application and application resources.
    def initialize
      if Halcyon.config.nil?
        if File.exist?(Halcyon::Runner.config_path)
          Halcyon.config = Halcyon::Runner.load_config
        else
          Halcon.config = Halcyon::Application::DEFAULT_OPTIONS
        end
      end
      
      # Set application name
      Halcyon.app = Halcyon.config[:app] || Halcyon.root.split('/').last.camel_case
      
      # Setup logger
      if Halcyon.config[:logger]
        Halcyon.config[:logging] = (Halcyon.config[:logging] || Halcyon::Application::DEFAULT_OPTIONS[:logging]).merge({
          :type => Halcyon.config[:logger].class.to_s,
          :logger => Halcyon.config[:logger]
        })
      end
      Halcyon::Logging.set((Halcyon.config[:logging][:type] rescue nil))
      Halcyon.logger = Halcyon::Logger.setup(Halcyon.config[:logging])
      
      # Run initializers
      Dir.glob([Halcyon.root/'config'/'initialize.rb', Halcyon.root/'config'/'initialize'/'*']).each do |initializer|
        require initializer.chomp('.rb')
        self.logger.debug "Init: #{File.basename(initializer).chomp('.rb').camel_case}"
      end
      
      # Setup autoloads for Controllers found in Halcyon.root/'app'
      Dir.glob(Halcyon.root/'app'/'*').each do |controller|
        require controller.chomp('.rb')
        self.logger.debug "Load: #{File.basename(controller).chomp('.rb').camel_case} Controller"
      end
      
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
      
      # Loads the configuration file specified into <tt>Halcyon.config</tt>.
      #   +file+ the configuration file to load
      # 
      # Examples
      #   Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
      #   Halcyon.config #=> {:allow_from => :all, :logging => {...}, ...}.to_mash
      # 
      # Returns {Symbol:key => String:value}.to_mash
      def load_config(file=Halcyon::Runner.config_path)
        if File.exist?(file)
          require 'yaml'
          
          # load the config file
          begin
            config = YAML.load_file(file).to_mash
          rescue Errno::EACCES
            raise LoadError.new("Can't access #{file}, try 'sudo #{$0}'")
          end
        else
          warn "#{file} not found, ensure the path to this file is correct. Ignoring."
          nil
        end
      end
      
    end
    
  end
end
