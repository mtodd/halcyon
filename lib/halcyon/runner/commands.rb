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
          log = ''
          Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
          Halcyon.config['logger'] = Logger.new(StringIO.new(log))
          app = Halcyon::Runner.new
          response = nil
          
          # Setup helper methods
          Object.send(:define_method, :usage) do
            msg = <<-"end;"
              
              These methods will provide you with most of the
              functionality you will need to test your app.
              
              #app      The loaded application
              #log      The contents of the log
              #tail     The tail end of the log
              #clear    Clears the log
              #get      Sends a GET request to #app
                        Ex: get '/controller/action'
              #post     Sends a POST request to #app
              #response Response of the last #get or #post request
              
              #get and #post both require path, #post requires
              params, which can be an empty hash (a {}):
              
              Ex: get '/foo'
                  post '/bar', {}
              
            end;
            puts msg.gsub(/^[ ]{14}/, '')
          end
          Object.send(:define_method, :app) { app }
          Object.send(:define_method, :log) { log }
          Object.send(:define_method, :tail) { puts log.split("\n").reverse[0..5].reverse.join("\n") }
          Object.send(:define_method, :clear) { log = '' }
          Object.send(:define_method, :get) { |path| response = Rack::MockRequest.new(app).get(path); JSON.parse(response.body) }
          Object.send(:define_method, :post) { |path, params| response = Rack::MockRequest.new(app).post(path, params); JSON.parse(response.body) }
          Object.send(:define_method, :response) { response }
          
          # Let users know what methods and values are available
          puts "Call #usage for usage details."
          
          # Start IRB session
          IRB.start
          
          exit
        end
        alias_method :interactive, :console
        alias_method :irb, :console
        
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
