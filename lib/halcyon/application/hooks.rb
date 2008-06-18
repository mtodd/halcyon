module Halcyon
  class Application
    
    # Helper that provides access to setting and running hooks.
    # 
    module Hooks
      
      # Extends the target with the class methods necessary.
      def self.included(target)
        target.extend(ClassMethods)
      end
      
      module ClassMethods
        
        # Sets the startup hook to the proc.
        # 
        # Use this to initialize application-wide resources, such as database
        # connections.
        # 
        # Use initializers where possible.
        # 
        def startup &hook
          Halcyon.hooks[:startup] << hook
        end
      
        # Sets the shutdown hook to the proc.
        # 
        # Close any resources opened in the +startup+ hook.
        # 
        def shutdown &hook
          Halcyon.hooks[:shutdown] << hook
        end
        
      end
      
    end
  end
end
