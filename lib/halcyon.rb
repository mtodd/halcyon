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
#   Halcyon.version #=> "0.5.1"
# 
module Halcyon
  
  VERSION = [0,5,1] unless defined?(Halcyon::VERSION)
  
  autoload :Application, 'halcyon/application'
  autoload :Client, 'halcyon/client'
  autoload :Config, 'halcyon/config'
  autoload :Controller, 'halcyon/controller'
  autoload :Exceptions, 'halcyon/exceptions'
  autoload :Logging, 'halcyon/logging'
  autoload :Runner, 'halcyon/runner'
  
  include Halcyon::Config::Helpers
  
  class << self
    
    attr_accessor :logger
    attr_accessor :config
    
    def version
      VERSION.join('.')
    end
    
    # The root directory of the current application.
    # 
    # Returns String:root_directory
    # 
    def root
      self.config[:root] || Dir.pwd rescue Dir.pwd
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
