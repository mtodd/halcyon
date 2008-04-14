module Halcyon
  module Logging
    module Helpers
      
      def self.included(target)
        target.extend(ClassMethods)
      end
      
      # The current application logger instance.
      # 
      # Examples
      #   self.logger.debug "Deleting user's cached data"
      # 
      # Returns Logger:logger
      def logger
        Halcyon.logger
      end
      
      module ClassMethods
        
        # The current application logger instance, usable in the class context.
        # This means you can call <tt>self.logger</tt> from inside of class
        # methods, filters, etc.
        # 
        # Examples
        #   self.logger.debug "Test message"
        # 
        # Returns Logger:logger
        def logger
          Halcyon.logger
        end
        
      end
      
    end
  end
end
