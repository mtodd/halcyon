module Halcyon
  class Config
    module Helpers
      
      # Extends the target class with the Configurable and Accessors helpers.
      def self.included(target)
        target.extend(Configurable)
        target.extend(Accessors)
      end
      
      # Provides several convenience accessors for configuration values,
      # including these:
      # * <tt>app</tt>: the app name
      # * <tt>root</tt>: the application working directory
      # * <tt>db</tt>: database configuration settings
      # 
      module Accessors
        
        # Accesses the <tt>app</tt> config value which is the constantized
        # version of the application name (which can be set manually in the
        # config file as <tt>app: NameOfApp</tt>, defaulting to a camel case
        # version of the application directory name).
        # 
        def app
          self.config[:app] || ::File.dirname(self.root).camel_case
        end
        
        # Sets the application name.
        # 
        def app=(name)
          self.config[:app] = name
        end
        
        # Accesses the <tt>root</tt> config value which is the root of the
        # current Halcyon application (usually <tt>Dir.pwd</tt>).
        # 
        # Defaults to <tt>Dir.pwd</tt>
        # 
        def root
          self.config[:root] || Dir.pwd rescue Dir.pwd
        end
        
        # Sets the application root.
        # 
        def root=(path)
          self.config[:root] = path
        end
        
        # Accesses the <tt>db</tt> config value. Intended to contain the
        # database configuration values for whichever ORM is used.
        # 
        def db
          self.config[:db]
        end
        
        # Sets the database settings.
        # 
        def db=(config)
          self.config[:db] = config
        end
        
        # Accesses the <tt>environment</tt> config value. Intended to contain
        # the environment the application is running in.
        # 
        # Defaults to the <tt>development</tt> environment.
        # 
        def environment
          self.config[:environment] || :development
        end
        alias_method :env, :environment
        
        # Sets the environment config value.
        # 
        def environment=(env)
          self.config[:environment] = env.to_sym
        end
        alias_method :env=, :environment=
        
        # Provides a proxy to the Halcyon::Config::Paths instance.
        # 
        def paths
          self.config[:paths]
        end
        
      end
      
      # Provides dynamic creation of configuration attribute accessors.
      # 
      module Configurable
        
        # Defines a dynamic accessor for configuration attributes.
        # 
        # Examples:
        # 
        #   Halcyon.configurable(:db)
        #   Halcyon.db = {...}
        #   Halcyon.config[:db] #=> {...}
        #   Halcyon.config[:db] = true
        #   Halcyon.db #=> true
        # 
        def configurable(attribute)
          eval <<-"end;"
            def #{attribute.to_s}
              Halcyon.config[:#{attribute.to_s}]
            end
            def #{attribute.to_s}=(value)
              value = value.to_mash if value.is_a?(Hash)
              Halcyon.config[:#{attribute.to_s}] = value
            end
          end;
        end
        alias_method :configurable_attr, :configurable
        
        # Defines a dynamic reader for configuration attributes, accepting
        # either a string or a block to perform the action.
        # 
        # Examples:
        # 
        #   Halcyon.configurable_reader(:foo) do
        #     self.config[:foo].to_sym
        #   end
        # 
        # OR
        # 
        #   Halcyon.configurable_reader(:foo, "Halcyon.config[%s].to_sym")
        # 
        def configurable_reader(attribute, code=nil, &block)
          if block_given? and not code
            Halcyon.class.send(:define_method, attribute.to_sym, block)
          elsif code and not block_given?
            Halcyon.class.send(:eval, <<-"end;")
              def #{attribute.to_s}
                #{code % [attribute.to_sym.inspect]}
              end
            end;
          else
            raise ArgumentError.new("Either a block or a code string should be supplied.")
          end
        end
        alias_method :configurable_attr_reader, :configurable_reader
        
        # Defines a dynamic writer for configuration attributes, accepting
        # either a string or a block to perform the action.
        # 
        # Examples:
        # 
        #   Halcyon.configurable_writer(:foo) do |val|
        #     self.config[:foo] = val.to_sym
        #   end
        # 
        # OR
        # 
        #   Halcyon.configurable_reader(:foo, "Halcyon.config[%s] = value.to_sym")
        # 
        def configurable_writer(attribute, code=nil, &block)
          if block_given? and not code
            Halcyon.class.send(:define_method, :"#{attribute}=", block)
          elsif code and not block_given?
            Halcyon.class.send(:eval, <<-"end;")
              def #{attribute.to_s}=(value)
                #{code % [attribute.to_sym.inspect]}
              end
            end;
          else
            raise ArgumentError.new("Either a block or a code string should be supplied.")
          end
        end
        alias_method :configurable_attr_writer, :configurable_writer
        
      end
      
    end
  end
end
