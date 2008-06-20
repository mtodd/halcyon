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
            command = "thin start -R runner.ru #{argv.join(' ')}"
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
          require 'logger'
          require 'irb'
          require 'irb/completion'
          if File.exists? '.irbrc'
            ENV['IRBRC'] = '.irbrc'
          end
          
          # Set up the application
          Object.instance_eval do
            $log = ''
            $app = Halcyon::Runner.new do |c|
              c[:logger] = Logger.new(StringIO.new($log))
            end
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
          app_name = argv.last
          
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
            opts.on("-G", "--git-commit", "Initialize a Git repo and commit") { options[:git] = options[:git_commit] = true }
            
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
          
          # Create a Git repository in the new app dir
          if options[:git]
            system("cd #{app_name} && git init -q && cd #{Dir.pwd}")
            puts "Initialized Git repository in #{app_name}/"
            File.open(File.join("#{app_name}",'.gitignore'),"w") {|f| f << "log/*.log" }
            File.open(File.join("#{app_name}",'log','.gitignore'),"w") {|f| f << "" }
          end
          
          # commit to the git repo
          if options[:git_commit]
            system("cd #{app_name} && git add . && git commit -m 'Initial import.' -q && cd #{Dir.pwd}")
            puts "Committed empty application in #{app_name}/"
            puts "Run `git commit --amend` to change the commit message."
          end
        end
        
      end
    end
  end
end
