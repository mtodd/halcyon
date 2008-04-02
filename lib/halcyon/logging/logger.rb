require 'logger'
module Halcyon
  module Logging
    class Logger < ::Logger
      
      class << self
        
        def setup(config)
          logger = config[:logger] || self.new(config[:file] || STDOUT)
          logger.formatter = proc{|s,t,p,m|"%5s [%s] (%s) %s :: %s\n" % [s, t.strftime("%Y-%m-%d %H:%M:%S"), $$, p, m]}
          logger.progname = Halcyon.app
          logger.level = Logger.const_get((config[:level] || 'info').upcase)
          logger
        end
        
      end
      
    end
  end
end
