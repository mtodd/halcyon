require 'swiftcore/Analogger/Client'
module Halcyon
  module Logging
    class Analogger < Swiftcore::Analogger::Client
      
      class << self
        
        def setup(config)
          self.new((config[:app] || Halcyon.app), config[:host], config[:port].to_s, config[:key])
        end
        
      end
      
      %w(debug info warn error fatal unknown).each do |level|
        
        eval <<-"end;"
          def #{level}(message)
            self.log('#{level}', message)
          end
        end;
        
      end
      
      def <<(message)
        # Should << be assumed as INFO level?
        self.log('info', message)
      end
      
    end
  end
end
