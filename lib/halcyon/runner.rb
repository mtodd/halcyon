# Modelled after Thin's Runner, found at
# http://github.com/macournoyer/thin/tree/master/lib/thin/runner.rb

module Halcyon
  # = CLI Runner
  # Parse options and start serving the app
  class Runner
    
    attr :options
    
    def initialize(argv)
      @options = {
        :root => Dir.pwd,
        :logger => Logger.new(STDOUT),
        :allow_from => :all
      }
      
      begin
        parser.parse! argv
      rescue OptionParser::InvalidOption => e
        abort "You used an unsupported option. Try: halcyon -h"
      end
    end
    
    def parser
      OptionParser.new("", 24, '  ') do |opts|
        opts.banner << "Halcyon, JSON App Framework\n"
        opts.banner << "http://halcyon.rubyforge.org/\n"
        opts.banner << "\n"
        opts.banner << "Usage: halcyon [options] appname\n"
        opts.banner << "\n"
        opts.banner << "Put -c or --config first otherwise it will overwrite higher precedence options."
        
        opts.separator ""
        opts.separator "Options:"
        
        opts.on("-d", "--debug", "set debugging flag (set $debug to true)") { $debug = true }
        opts.on("-D", "--Debug", "enable verbose debugging (set $debug and $DEBUG to true)") { $debug = true; $DEBUG = true }
        opts.on("-w", "--warn", "turn warnings on for your script") { $-w = true }
        
        opts.on("-I", "--include PATH", "specify $LOAD_PATH (multiples OK)") do |path|
          $:.unshift(*path.split(":"))
        end
        
        opts.on("-r", "--require LIBRARY", "require the library, before executing your script") do |library|
          require library
        end
        
        opts.on("-c", "--config PATH", "load configuration (YAML) from PATH") do |conf_file|
          if File.exist?(conf_file)
            require 'yaml'

            # load the config file
            begin
              conf = YAML.load_file(conf_file)
            rescue Errno::EACCES
              abort("Can't access #{conf_file}, try 'sudo #{$0}'")
            end

            # store config file path so SIGHUP and SIGUSR2 will reload the config in case it changes
            options[:config_file] = conf_file

            # parse config
            case conf
            when String
              # config file given was just the commandline options
              ARGV.replace(conf.split)
              opts.parse! ARGV
            when Hash
              conf.to_mash
              options = options.merge(conf)
            when Array
              # TODO (MT) support multiple servers (or at least specifying which
              # server's configuration to load)
              warn "Your configuration file is setup for multiple servers. This is not a supported feature yet."
              warn "However, we've pulled the first server entry as this server's configuration."
              # an array of server configurations
              # default to the first entry since multiple server configurations isn't
              # precisely worked out yet.
              options = options.merge(conf[0])
            else
              abort "Config file in an unsupported format. Config files must be YAML or the commandline flags"
            end
          else
            abort "Config file failed to load. #{conf_file} was not found. Correct the path and try again."
          end
        end
        
        opts.on("-s", "--server SERVER", "serve using SERVER (default: #{options[:server]})") do |serv|
          options[:server] = serv
        end
        
        opts.on("-o", "--host HOST", "listen on HOST (default: #{options[:host]})") do |host|
          options[:host] = host
        end
        
        opts.on("-p", "--port PORT", "use PORT (default: #{options[:port]})") do |port|
          options[:port] = port
        end
        
        opts.on("-l", "--logfile PATH", "log access to PATH (default: #{options[:log_file]})") do |log_file|
          options[:log_file] = log_file
        end
        
        opts.on("-L", "--loglevel LEVEL", "log level (default: #{options[:log_level]})") do |log_file|
          options[:log_level] = log_file
        end
        
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        
        opts.on_tail("-v", "--version", "Show version") do
          # require 'halcyon'
          puts "Halcyon #{Halcyon::Server.version}"
          exit
        end
      end
    end
    
  end
end
