require 'logging'
module Halcyon
  module Logging
    class Logging < Logging::Logger
      
      class << self
        
        def setup(config)
          logger = config[:logger] || ::Logging.logger(config[:file] || STDOUT)
          logger.level = config[:level].downcase.to_sym
          logger.instance_variable_get("@appenders")[0].instance_variable_set("@layout", ::Logging::Layouts::Pattern.new(:pattern => "%5l [%d] (%p) #{Halcyon.app} :: %m\n", :date_pattern => "%Y-%m-%d %H:%M:%S"))
          logger
        end
        
      end
      
    end
  end
end
