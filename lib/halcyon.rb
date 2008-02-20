#!/usr/bin/env ruby
#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

$:.unshift File.dirname(__FILE__)

#--
# dependencies
#++

%w(rubygems merb/core_ext).each {|dep|require dep}

#--
# module
#++

module Halcyon
  VERSION = [0,4,1]
  def self.version
    VERSION.join('.')
  end
  
  #--
  # Module Autoloading
  #++
  
  class Server
    module Auth
      autoload :Basic, 'halcyon/server/auth/basic'
    end
  end
  
  class Application
  end

  class Client
  end
  
end

%w(halcyon/exceptions).each {|dep|require dep}
