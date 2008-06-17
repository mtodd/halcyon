module Halcyon
  class Config
    class Paths
      
      attr_accessor :paths
      
      # Creates a profile with the default paths.
      def initialize(paths={})
        self.paths = Mash.new(self.defaults.merge(paths))
      end
      
      # Gets the path for the specified entity.
      # 
      # Examples:
      # 
      #   Halcyon.paths.for(:log) #=> "/path/to/app/log/"
      # 
      def for(key)
        self.paths[key] or raise ArgumentError.new("Path is not defined")
      end
      
      # Alias to <tt>for</tt>.
      # 
      def [](key)
        self.for(key)
      end
      
      # Defines a path for the specified entity.
      # 
      # Examples:
      # 
      #   Halcyon.paths.define(:tmp, Halcyon.root/'tmp')
      # 
      # OR
      # 
      #   Halcyon.paths.define(:tmp => Halcyon.root/'tmp')
      # 
      def define(key_or_hash, value = nil)
        if key_or_hash.is_a?(Hash) and value.nil?
          key_or_hash.keys.each do |key|
            self.define(key, key_or_hash[key])
          end
        else
          self.paths[key_or_hash] = value
        end
      end
      
      # Alias for <tt>define</tt>.
      # 
      def []=(key, value)
        self.define(key, value)
      end
      
      # Default paths.
      # 
      def defaults
        {
          :controller => Halcyon.root/'app',
          :model => Halcyon.root/'app'/'models',
          :lib => Halcyon.root/'lib',
          :config => Halcyon.root/'config',
          :init => Halcyon.root/'config'/'init',
          :log => Halcyon.root/'log'
        }
      end
      
      def inspect
        "#<Halcyon::Config::Paths #{self.paths.keys.join(', ')}>"
      end
      
    end
  end
end
