module Halcyon
  module Logging
    
    autoload :Logger, 'halcyon/logging/logger'
    autoload :Logging, 'halcyon/logging/logging'
    autoload :Analogger, 'halcyon/logging/analogger'
    autoload :Log4r, 'halcyon/logging/log4r'
    
    class << self
      def set(logger = 'Logger')
        Halcyon.const_set :Logger, Halcyon::Logging.const_get(logger)
      end
    end
    
  end
end
