$:.unshift File.dirname(__FILE__)

%w(rubygems rack merb-core/core_ext merb-core/vendor/facets merb-core/dispatch/router json uri).each {|dep|require dep}

# Provides global values, like the root of the current application directory,
# the current logger, the application name, and the framework version.
# 
# Examples
#   Halcyon.app #=> AppName
#   Halcyon.root #=> Dir.pwd
#   Halcyon.config #=> {:allow_from => :all, :logging => {...}, ...}
#   Halcyon.paths #=> {:config => Halcyon.root/'config', ...}
#   Halcyon.logger #=> #<Logger>
#   Halcyon.version #=> "0.5.2"
# 
module Halcyon
  
  VERSION = [0,5,2] unless defined?(Halcyon::VERSION)
  
  autoload :Application, 'halcyon/application'
  autoload :Client, 'halcyon/client'
  autoload :Config, 'halcyon/config'
  autoload :Controller, 'halcyon/controller'
  autoload :Exceptions, 'halcyon/exceptions'
  autoload :Logging, 'halcyon/logging'
  autoload :Runner, 'halcyon/runner'
  
  include Config::Helpers
  
  class << self
    
    attr_accessor :logger
    attr_writer :config
    
    def version
      VERSION.join('.')
    end
    
    # The default <tt>root</tt> setting, overwritten by a configuration helper.
    # This is so that the paths can be loaded when first booting the app.
    # This won't be necessary for certain cases where the paths the root is
    # manually configured, but for all other cases it can cause problems.
    # 
    def root
      Dir.pwd
    end
    
    # Configuration accessor which creates a configuration object when
    # necessary.
    # 
    def config
      @config ||= Halcyon::Config.new
    end
    
    # Tests for Windows platform (to compensate for numerous Windows-specific
    # bugs and oddities.)
    # 
    # Returns Boolean:is_windows
    # 
    def windows?
      RUBY_PLATFORM =~ /mswin/
    end
    
    # Tests for Linux platform.
    # 
    # Returns Boolean:is_linux
    # 
    def linux?
      RUBY_PLATFORM =~ /linux/
    end
    
  end
  
end

# Include the klass#logger and klass.logger accessor methods into Object.
Object.send(:include, Halcyon::Logging::Helpers)

# The server-interface framework.
# 
module Rack
  
  autoload :JSONP, 'rack/jsonp'
  
end
