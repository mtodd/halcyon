#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

$:.unshift File.dirname(File.join('..', __FILE__))
$:.unshift File.dirname(__FILE__)

#--
# dependencies
#++

%w(rubygems halcyon rack).each {|dep|require dep}
begin
  require 'json/ext'
rescue LoadError => e
  warn 'Using the Pure Ruby JSON... install the json gem to get faster JSON parsing.'
  require 'json/pure'
end

#--
# module
#++

module Halcyon
  
  # = Server Communication and Protocol
  # 
  # Server tries to comply with appropriate HTTP response codes, as found at
  # <http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html>. However, all
  # responses are JSON encoded as the server expects a JSON parser on the
  # client side since the server should not be processing requests directly
  # through the browser. The server expects the User-Agent to be one of:
  #   +"User-Agent" => "JSON/1.1.1 Compatible (en-US) Halcyon/0.0.12 Client/0.0.1"+
  #   +"User-Agent" => "JSON/1.1.1 Compatible"+
  # The server also expects to accept application/json and be originated
  # from the local host (though this can be overridden).
  # 
  # = Usage
  # 
  # For documentation on using Halcyon, check out the Halcyon::Server::Base and
  # Halcyon::Client::Base classes which contain much more usage documentation.
  class Server
    def self.version
      VERSION.join('.')
    end
    
    #--
    # module dependencies
    #++
    
    autoload :Base, 'halcyon/server/base'
    autoload :Router, 'halcyon/server/router'
    
  end
  
end

# Loads the Exceptions class first which sets up all the dynamically generated
# exceptions used by the system. Must occur before Base is loaded since Base
# depends on it.
%w(halcyon/server/exceptions).each {|dep|require dep}
