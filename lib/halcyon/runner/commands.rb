module Halcyon
  class Runner
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
