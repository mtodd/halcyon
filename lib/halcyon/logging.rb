module Halcyon
  module Logging
    
    autoload :Logger, 'halcyon/logging/logger'
    autoload :Logging, 'halcyon/logging/logging'
    autoload :Analogger, 'halcyon/logging/analogger'
    autoload :Log4r, 'halcyon/logging/log4r'
    
    class << self
      
      # Sets up the Halcyon::Logger constant to reflect the logging
      # configuration settings.
      #   +logger+ the name of the logging type
      # 
      # Configs
      #   <tt>Halcyon.config[:logging][:type]</tt> #=> <tt>String:Logger</tt>
      #     Logger              => specifies Logger
      #     Logging             => specifies Logging
      #     Analogger           => specifies Analogger
      #     Log4r               => specifies Log4r
      def set(logger = 'Logger')
        Halcyon.send(:remove_const, :Logger) if Halcyon.const_defined? :Logger
        Halcyon.const_set :Logger, Halcyon::Logging.const_get(logger)
      end
      
    end
    
  end
end
