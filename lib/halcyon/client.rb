#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

$:.unshift File.dirname(File.join('..', __FILE__))
$:.unshift File.dirname(__FILE__)

#--
# dependencies
#++

%w(halcyon rubygems json).each {|dep|require dep}

#--
# module
#++

module Halcyon
  
  # The Client library provides a simple way to package up a client lib to
  # simplify communicating with the accompanying Halcyon server app.
  # 
  # = Usage
  # 
  # For documentation on using Halcyon, check out the Halcyon::Server::Base and
  # Halcyon::Client::Base classes which contain much more usage documentation.
  class Client
    VERSION.replace [0,2,12]
    def self.version
      VERSION.join('.')
    end
    
    #--
    # module dependencies
    #++
    
    autoload :Base, 'halcyon/client/base'
    autoload :Exceptions, 'halcyon/client/exceptions'
    autoload :Router, 'halcyon/client/router'
    
  end
end
