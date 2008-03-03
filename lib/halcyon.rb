#!/usr/bin/env ruby
#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

$:.unshift File.dirname(__FILE__)

%w(rubygems merb/core_ext).each {|dep|require dep}

module Halcyon
  
  VERSION = [0,5,0]
  def self.version
    VERSION.join('.')
  end
  
  autoload :Application, 'halcyon/application'
  
  class Server
    module Auth
      autoload :Basic, 'halcyon/server/auth/basic'
    end
  end
  
end

%w(halcyon/exceptions).each {|dep|require dep}
