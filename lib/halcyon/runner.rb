# Partly modeled after Thin's Runner, found at
# http://github.com/macournoyer/thin/tree/master/lib/thin/runner.rb

require 'optparse'

module Halcyon
  
  # = CLI Runner
  # Parse options and start serving the app
  class Runner
    
    autoload :Commands, 'halcyon/runner/commands'
    
    # Make sure that the Halcyon.config hash is setup
    Halcyon.config ||= Mash.new(Halcyon::Application::DEFAULT_OPTIONS)
    
    class << self
      
      # Runs commands from the CLI; foregoes actually running the app
      def run!(argv=ARGV)
        Commands.send(argv.shift, argv)
      end
      
    end
    
    # Sets up the application to run
    def initialize
      # Set application name
      Halcyon.app = Halcyon.root.split('/').last.camel_case
      
      # Setup logger
      if Halcyon.config[:logger]
        Halcyon.config[:logging] = {:type => Halcyon.config[:logger].class.to_s, :logger => Halcyon.config[:logger]}
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
    
    def call(env)
      @app.call(env)
    end
    
    def logger
      Halcyon.logger
    end
    
    class << self
      
      def logger
        Halcyon.logger
      end
      
      def load_config file
        if File.exist?(file)
          require 'yaml'
          
          # load the config file
          begin
            Halcyon.config = (Halcyon.config.merge YAML.load_file(file)).to_mash
          rescue Errno::EACCES
            abort("Can't access #{file}, try 'sudo #{$0}'")
          end
          
          # store config file path so SIGHUP and SIGUSR2 will reload the config in case it changes
          Halcyon.config[:config_file] = file
          
          Halcyon.config
        else
          abort "Config file failed to load. #{file} was not found. Correct the path and try again."
        end
      end
      
    end
    
  end
end
