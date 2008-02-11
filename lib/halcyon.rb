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
  VERSION = [0,4,0]
  def self.version
    VERSION.join('.')
  end
  
  # = Introduction
  # 
  # Halcyon is a JSON Web Server Framework intended to be used for fast, small
  # data transactions, like for AJAX-intensive sites or for special services like
  # authentication centralized for numerous web apps in the same cluster.
  # 
  # The possibilities are pretty limitless: the goal of Halcyon was simply to be
  # lightweight, fast, simple to implement and use, and able to be extended.
  # 
  # == Usage
  # 
  # For documentation on using Halcyon, check out the Halcyon::Server::Base and
  # Halcyon::Client::Base classes which contain much more usage documentation.
  def introduction
    abort "READ THE DAMNED RDOCS!"
  end
  
  #--
  # Module Autoloading
  #++
  
  class Server
    module Auth
      autoload :Basic, 'halcyon/server/auth/basic'
    end
  end
  
end

%w(halcyon/exceptions).each {|dep|require dep}
