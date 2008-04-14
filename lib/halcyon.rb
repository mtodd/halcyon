$:.unshift File.dirname(__FILE__)

%w(rubygems rack merb-core/core_ext merb-core/vendor/facets merb-core/dispatch/router json uri).each {|dep|require dep}

# Provides global values, like the root of the current application directory,
# the current logger, the application name, and the framework version.
# 
# Examples
#   Halcyon.app #=> AppName
#   Halcyon.root #=> Dir.pwd
#   Halcyon.config #=> {:allow_from => :all, :logging => {...}, ...}
#   Halcyon.logger #=> #<Logger>
#   Halcyon.version #=> "0.5.0"
module Halcyon
  
  VERSION = [0,5,0] unless defined?(Halcyon::VERSION)
  
  autoload :Application, 'halcyon/application'
  autoload :Client, 'halcyon/client'
  autoload :Controller, 'halcyon/controller'
  autoload :Exceptions, 'halcyon/exceptions'
  autoload :Logging, 'halcyon/logging'
  autoload :Runner, 'halcyon/runner'
  
  class << self
    
    attr_accessor :app
    attr_accessor :logger
    attr_accessor :config
    
    def version
      VERSION.join('.')
    end
    
    # The root directory of the current application.
    # 
    # Returns String:root_directory
    def root
      self.config[:root] || Dir.pwd rescue Dir.pwd
    end
    
    # Retreives the current database configuration settings from
    # <tt>Halcyon.config</tt>.
    def db
      Halcyon.config[:db]
    end
    
    # Set the DB configuration settings with the value of +config+ which is
    # stored in the <tt>Halcyon.config</tt> hash.
    #   +config+ the configuration settings for the Database.
    def db=(config = {})
      Halcyon.config[:db] = config.to_mash
    end
    
  end
  
end

# Include the klass#logger and klass.logger accessor methods into Object.
Object.send(:include, Halcyon::Logging::Helpers)
