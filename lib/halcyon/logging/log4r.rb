require 'log4r'
module Halcyon
  module Logging
    class Log4r < Log4r::Logger
      
      class << self
        
        def setup(config)
          raise NotImplementedError
          logger = self.new(config[:label] || Halcyon.app)
          logger.outputters = Log4r::Outputter.stdout # TODO: Expand this
          logger
        end
        
      end
      
    end
  end
end
