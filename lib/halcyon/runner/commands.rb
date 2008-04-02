require 'optparse'

module Halcyon
  class Runner
    
    autoload :Helpers, 'halcyon/runner/helpers'
    
    class Commands
      class << self
        
        # Run the Halcyon application
        def start(argv)
          options = {
            :port => 4647,
            :server => (Gem.searcher.find('thin').nil? ? 'mongrel' : 'thin')
          }
          
          OptionParser.new do |opts|
            opts.banner = "Usage: halcyon start [options]"
            
            opts.separator ""
            opts.separator "Start options:"
            opts.on("-s", "--server SERVER", "") { |server| options[:server] = server }
            
            begin
              opts.parse! argv
            rescue OptionParser::InvalidOption => e
              # the other options can be used elsewhere, like in RubiGen
              argv = e.recover(argv)
            end
          end
          
          if options[:server] == 'thin'
            # Thin is installed
            command = "thin start -r runner.ru #{argv.join(' ')}"
          else
            # Thin is not installed
            command = "rackup runner.ru -s #{options[:server]} #{argv.join(' ')}"
          end
          
          # run command
          exec command
        end
        
        # Start the Halcyon server up in interactive mode
        def console(argv)
          # Notify user of environment
          puts "(Starting Halcyon app in console...)"
          
          # Add ./lib to load path
          $:.unshift(Halcyon.root/'lib')
          
          # prepare environment for IRB
          ARGV.clear
          require 'rack/mock'
          require 'irb'
          require 'irb/completion'
          if File.exists? '.irbrc'
            ENV['IRBRC'] = '.irbrc'
          end
          
          # Set up the application
          Object.instance_eval do
            $log = ''
            Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
            Halcyon.config[:logger] = Logger.new(StringIO.new($log))
            $app = Halcyon::Runner.new
            $response = nil
          end
          
          # Setup helper methods
          Object.send(:include, Halcyon::Runner::Helpers::CommandHelper)
          
          # Let users know what methods and values are available
          puts "Call #usage for usage details."
          
          # Start IRB session
          IRB.start
          
          exit
        end
        alias_method :interactive, :console
        alias_method :irb, :console
        alias_method :"-i", :console
        
        # Generate a new Halcyon application
        def init(argv)
          options = {
            :generator => 'halcyon',
            :git => false
          }
          
          OptionParser.new do |opts|
            opts.banner = "Usage: halcyon init [options]"
            
            opts.separator ""
            opts.separator "Generator options:"
            opts.on("-f", "--flat", "") { options[:generator] = 'halcyon_flat' }
            
            opts.separator ""
            opts.separator "Additional options:"
            opts.on("-g", "--git", "Initialize a Git repository when finished generating") { options[:git] = true }
            
            begin
              opts.parse! argv
            rescue OptionParser::InvalidOption => e
              # the other options can be used elsewhere, like in RubiGen
            end
          end
          
          require 'rubigen'
          require 'rubigen/scripts/generate'
          RubiGen::Base.use_application_sources!
          RubiGen::Base.sources << RubiGen::PathSource.new(:custom, File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', "support/generators")))
          RubiGen::Scripts::Generate.new.run(argv, :generator => options[:generator])
        end
        
      end
    end
  end
end
