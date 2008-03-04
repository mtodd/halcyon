#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

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
