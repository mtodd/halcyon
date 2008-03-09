#!/usr/bin/env ruby
#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

$:.unshift File.dirname(__FILE__)

%w(rubygems rack merb/core_ext merb/router json uri logger).each {|dep|require dep}

module Halcyon
  
  VERSION = [0,5,0]
  
  autoload :Runner, 'halcyon/runner'
  autoload :Exceptions, 'halcyon/exceptions'
  autoload :Application, 'halcyon/application'
  autoload :Controlle, 'halcyon/controller'
  autoload :Client, 'halcyon/client'
  
  class << self
    
    attr_accessor :config
    attr_accessor :logger
    
    def version
      VERSION.join('.')
    end
    
    def root
      self.config[:root] || Dir.pwd rescue Dir.pwd
    end
    
  end
  
end
