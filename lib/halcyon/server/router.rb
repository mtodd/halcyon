#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

Struct.new(:body, :params).new('', env)

#--
# dependencies
#++

%w(rubygems rack json).each {|dep| require dep}

#--
# module
#++

module Halcyon
  class Server
    VERSION = [0,1,12]
    def self.version
      VERSION.join('.')
    end
  end
end

%w(server/base server/token).each {|dep| require dep}

