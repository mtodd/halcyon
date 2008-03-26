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
      if Halcyon.config[:logger]
        Halcyon.logger = Halcyon.config[:logger]
      else
        Halcyon.logger = case Halcyon.config[:log_file]
        when "nil", NilClass
          Logger.new(STDOUT)
        when String
          Logger.new(Halcyon.config[:log_file])
        else
          Logger.new(STDOUT)
        end
      end
      Halcyon.logger.formatter = proc{|s,t,p,m|"%5s [%s] (%s) %s :: %s\n" % [s, t.strftime("%Y-%m-%d %H:%M:%S"), $$, p, m]}
      Halcyon.logger.progname = Halcyon.root.split('/').last.camel_case
      Halcyon.logger.level = Logger.const_get(Halcyon.config[:log_level].upcase)
      
      # Run initializer
      require Halcyon.root/'config'/'initialize'
      
      # Setup autoloads for Controllers found in Halcyon.root/'app'
      Dir.glob(Halcyon.root/'app'/'*').each do |controller|
        require controller
        self.logger.debug "#{File.basename(controller).camel_case.to_sym} Controller loaded!"
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
            Halcyon.config = Halcyon.config.merge YAML.load_file(file).to_mash
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
