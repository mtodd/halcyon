require 'rbconfig'

class HalcyonFlatGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])
  
  default_options   :shebang => DEFAULT_SHEBANG
  
  attr_reader :app_name, :module_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = args.shift
    @app_name     = File.basename(File.expand_path(@destination_root))
    @module_name  = app_name.camelize
    # extract_options
  end
  
  def manifest
    record do |m|
      source = File.expand_path(File.join(File.dirname(__FILE__), 'templates')) << File::Separator
      
      m.directory ''
      Dir[source + '**/*'].each do |path|
        path = path.sub(source, '')
        if File.directory?(source+path)
          m.directory path
        else
          m.template path, path
        end
      end
      m.directory 'log'
    end
  end
  
  protected
  def banner
    <<-"end;"
      Create a stub for #{File.basename $0} to get started.
      
      Usage: #{File.basename $0} [options] /path/to/your/app"
    end;
  end
  
  def add_options!(opts)
    opts.separator ''
    opts.separator "#{File.basename $0} options:"
    opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
  end
  
end
