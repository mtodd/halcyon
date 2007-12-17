#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

$:.unshift File.dirname(File.join('..', __FILE__))
$:.unshift File.dirname(__FILE__)

#--
# dependencies
#++

%w(halcyon rubygems rack json).each {|dep|require dep}

#--
# module
#++

module Halcyon
  
  # Server tries to comply with appropriate HTTP response codes, as found at
  # <http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html>. However, all
  # responses are JSON encoded as the server expects a JSON parser on the
  # client side since the server should not be processing requests directly
  # through the browser. The server expects the User-Agent to be one of:
  # +"User-Agent" => "JSON/1.1.1 Compatible (en-US) Halcyon/0.0.12 Client/0.0.1"+
  # +"User-Agent" => "JSON/1.1.1 Compatible"+
  # The server also expects to accept application/json and be originated
  # from the local host (though this can be overridden).
  class Server
    VERSION.replace [0,3,7]
    def self.version
      VERSION.join('.')
    end
    
    #--
    # module dependencies
    #++
    
    autoload :Base, 'halcyon/server/base'
    autoload :Exceptions, 'halcyon/server/exceptions'
    autoload :Router, 'halcyon/server/router'
    
  end
  
end

%w(server/exceptions).each {|dep|require dep}
