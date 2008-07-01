module Halcyon
  
  # Application configuration map.
  # 
  class Config
    
    attr_accessor :config
    
    autoload :Helpers, 'halcyon/config/helpers'
    autoload :Paths, 'halcyon/config/paths'
    autoload :File, 'halcyon/config/file'
    
    # Creates an empty configuration hash (Mash) and sets up the configuration
    # to whatever the settings are provided, merging over the defaults.
    # 
    # Examples:
    # 
    #   Halcyon::Config.new(:environment => :development)
    # 
    # OR
    # 
    #   Halcyon::Config.new(:allow_from => :all)
    # 
    # OR
    # 
    #   Halcyon::Config.new
    # 
    # OR
    # 
    #   Halcyon::Config.new do |c|
    #     c[:foo] = true
    #   end
    # 
    def initialize(config={}, &block)
      env = config.delete(:environment)
      self.config = Mash.new
      self.setup(self.defaults(env).merge(config))
      self.use(&block) if block_given?
    end
    
    # Sets the configuration up with the values given.
    # 
    def configure(config={})
      config.each do |(key, val)|
        self.config[key] = val
      end
    end
    
    # Sets up the configuration by storing the settings provided (via param or
    # via block).
    # 
    # Usage:
    # 
    #   Halcyon.config.setup do |c|
    #     c[:foo] = true
    #   end
    # 
    # or
    # 
    #   Halcyon.config.setup(:foo => true)
    # 
    def setup(config={})
      if block_given?
        yield(self.config.dup)
      end
      # merge new settings
      self.configure(config)
    end
    
    # Yields and returns the configuration.
    # 
    # Examples:
    # 
    #   Halcyon.config.use do |c|
    #     c[:foo] = true
    #   end
    # 
    def use
      if block_given?
        yield self.config
      end
      self.config
    end
    
    # Allows retrieval of single key config values and setting single config
    # values.
    # 
    # Examples:
    # 
    #   Halcyon.config.app #=> 'AppName'
    #   Halcyon.config[:app] #=> 'AppName'
    # 
    def method_missing(method, *args)
      if method.to_s[-1,1] == '='
        self.put(method.to_s.tr('=',''), *args)
      else
        self.get(method)
      end
    end
    
    # Get the configuration value associated with the key.
    # 
    # Examples:
    # 
    #   Halcyon.config.get(:app) #=> 'AppName'
    # 
    def get(key)
      self.config[key]
    end
    
    # Put the configuration value associated with the key or setup with a hash.
    # 
    # Examples:
    # 
    #   Halcyon.config.put(:app, 'AppName')
    # 
    # OR
    # 
    #   Halcyon.config.put(:app => 'AppName')
    # 
    def put(key_or_config_hash, value = nil)
      if value.nil? and key_or_config_hash.is_a?(Hash)
        self.configure(key_or_config_hash)
      else
        self.config[key_or_config_hash] = value
      end
    end
    
    # Removes the configuration value from the hash.
    # 
    # Examples:
    # 
    #   Halcyon.config.delete(:app) #=> 'AppName'
    # 
    def delete(key)
      self.config.delete(key)
    end
    
    # Alias for the <tt>get</tt> method.
    # 
    # Examples:
    # 
    #   Halcyon.config[:foo] #=> true
    # 
    def [](key)
      self.get(key)
    end
    
    # Alias for the <tt>put</tt> method. (Restricted to the key/value pair.)
    # 
    # Examples:
    # 
    #   Halcyon.config[:foo] = true
    # 
    def []=(key, value)
      self.put(key, value)
    end
    
    # Returns the configuration rendered as YAML.
    # 
    def to_yaml
      require 'yaml'
      self.config.to_hash.to_yaml
    end
    
    # Returns the configuration as a hash.
    # 
    def to_hash
      self.config.to_hash
    end
    
    # Shortcut for Halcyon::Config.defaults.
    # 
    def defaults(env = nil)
      Halcyon::Config.defaults(env)
    end
    
    # Loads the contents of a configuration file found at <tt>path</tt> and
    # merges it with the current configuration.
    # 
    def load_from(path)
      self.configure(Halcyon::Config::File.load(path))
      self
    end
    
    def inspect
      attrs = ""
      self.config.keys.each {|key| attrs << " #{key}=#{self.config[key].inspect}"}
      "#<Halcyon::Config#{attrs}>"
    end
    
    class << self
      
      # Default configuration values.
      # 
      # Defaults to the configuration for <tt>:development</tt>.
      # 
      def defaults(env = nil)
        base = {
          :app => nil,
          :root => Dir.pwd,
          :environment => :development,
          :allow_from => 'all',
          :logging => {
            :type => 'Logger',
            :level => 'debug'
          },
          :paths => Paths.new,
          :hooks => {:startup => [], :shutdown => []}
        }
        case (env || :development)
        when :development
          base.merge({
            :environment => :development
          })
        when :test
          base.merge({
            :app => 'Specs',
            :environment => :test,
            :logging => {
              :type => 'Logger',
              :level => 'warn',
              :file => 'log/test.log'
            }
          })
        when :console
          base.merge({
            :environment => :console
          })
        when :production
          base.merge({
            :environment => :production,
            :logging => {
              :type => 'Logger',
              :level => 'warn',
              :file => 'log/production.log'
            }
          })
        end
      end
      
      # Loads the contents of a configuration file found at <tt>path</tt>.
      # 
      def load_from(path)
        Halcyon::Config::File.load(path)
      end
      
    end
    
  end
  
end
