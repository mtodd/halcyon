#!/usr/bin/env ruby
#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

$:.unshift File.dirname(__FILE__)

#--
# dependencies
#++

%w(halcyon/support/hashext).each {|dep|require dep}

class Hash
  include HashExt::Keys
end

#--
# module
#++

module Halcyon
  VERSION = [0,3,7]
  def self.version
    VERSION.join('.')
  end
  
  #--
  # module dependencies
  #++
  
  autoload :Exceptions, 'halcyon/exceptions'
  autoload :Server, 'halcyon/server'
  autoload :Client, 'halcyon/client'

end
