require 'logging'
module Halcyon
  module Logging
    class Logging < Log4r::Logger
      
      class << self
        
        def setup(config)
          raise NotImplementedError
          # TODO: Needs to be expanded to set up the correct params; these will cause errors
          logger = config[:logger] || self.logger(config[:file] || STDOUT)
          logger.formatter = proc{|s,t,p,m|"%5s [%s] (%s) %s :: %s\n" % [s, t.strftime("%Y-%m-%d %H:%M:%S"), $$, p, m]}
          logger.level = config[:level].downcase.to_sym
          logger
        end
        
      end
      
    end
  end
end
