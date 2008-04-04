require 'log4r'
include Log4r
module Halcyon
  module Logging
    class Log4r < Log4r::Logger
      
      class << self
        
        def setup(config)
          logger = self.new(config[:label] || Halcyon.app)
          if config[:file]
            logger.outputters = Log4r::FileOutputter.new(:filename => config[:file])
          else
            logger.outputters = Log4r::Outputter.stdout
          end
          logger.level = Object.const_get((config[:level] || 'debug').upcase.to_sym)
          logger.outputters[0].formatter = Log4r::PatternFormatter.new(:pattern => "%5l [%d] (#{$$}) #{Halcyon.app} :: %m\n", :date_pattern => "%Y-%m-%d %H:%M:%S")
          logger
        end
        
      end
      
    end
  end
end
