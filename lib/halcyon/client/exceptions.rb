#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

#--
# module
#++

module Halcyon
  class Client
    class Base
      module Exceptions #:nodoc:
        
        #--
        # Base Halcyon Exception
        #++
        
        class Base < StandardError #:nodoc:
          attr_accessor :status, :error
          def initialize(status, error)
            @status = status
            @error = error
          end
        end
        
        #--
        # Exception classes
        #++
        
        Halcyon::Exceptions::HTTP_ERROR_CODES.to_a.each do |http_error|
          status, body = http_error
          class_eval(
            "class #{body.gsub(/ /,'')} < Base\n"+
            "  def initialize(s=#{status}, e='#{body}')\n"+
            "    super s, e\n"+
            "  end\n"+
            "end"
          );
        end
        
        #--
        # Exception Lookup
        #++
        
        def self.lookup(status)
          self.const_get(Halcyon::Exceptions::HTTP_ERROR_CODES[status].gsub(/ /,'').to_sym)
        end
        
      end
    end
  end
end
