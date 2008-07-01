require 'erb'

module Halcyon
  class Config
    
    # Class to assist with loading configuration from a file.
    # 
    # Examples:
    # 
    #   Halcyon::Config::File.new(file_name_or_path).to_hash #=> {...}
    # 
    class File
      
      attr_accessor :path
      attr_accessor :content
      
      # Creates a profile with the default paths.
      # 
      # * +file+ is the path to the file.
      # * +filter_config+ specifies whether to filter the contents through ERB
      #   before parsing it.
      # 
      def initialize(file, filter_config = true)
        if ::File.exist?(file)
          self.path = file
        elsif ::File.exist?(Halcyon.paths.for(:config)/file)
          self.path = Halcyon.paths.for(:config)/file
        else
          raise ArgumentError.new("Could not find #{self.path} (it does not exist).")
        end
        self.content = self.filter(::File.read(self.path), filter_config)
      end
      
      # Returns the loaded configuration file's contents parsed by the
      # marshal format loader (defaulting to YAML, also providing JSON).
      # 
      # Examples:
      # 
      #   p = Halcyon.paths.for(:config)/'config.yml'
      #   c = Halcyon::Config::File.new(p)
      #   c.to_hash #=> the contents of the config file parsed as YAML
      #   c.to_hash(:from_json) #=> same as above only parsed as JSON
      #   # parsing errors will happen if you try to use the wrong marshal
      #   # load method
      # 
      def to_hash(from = :from_yaml)
        Mash.new case from
        when :from_yaml
          require 'yaml'
          YAML.load(self.content)
        when :from_json
          JSON.parse(self.content)
        end
      end
      
      # Filters the contents through ERB.
      # 
      def filter(content, filter_through_erb)
        content =  ERB.new(content).result if filter_through_erb
        content
      end
      
      def inspect
        "#<Halcyon::Config::File #{self.path}>"
      end
      
      class << self
        
        # Provides a convenient way to load the configuration and return the
        # appropriate hash contents.
        # 
        def load(path)
          file = File.new(path)
          case path
          when /\.(yaml|yml)/
            file.to_hash
          when /\.(json)/
            file.to_hash(:from_json)
          end
        end
        
        # Loads the configuration file and parses it's contents as YAML.
        # This is a shortcut method.
        # 
        def load_from_yaml(path)
          self.new(path).to_hash
        end
        
        # Loads the configuration file and parses it's contents as JSON.
        # This is a shortcut method.
        # 
        def load_from_json(path)
          self.new(path).to_hash(:from_json)
        end
        
      end
      
    end
  end
end
