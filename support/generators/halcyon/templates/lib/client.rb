#--
# Client
#++

%w(rubygems halcyon/client).each {|dep|require dep}

module Sparrow
  
  class Client < Halcyon::Client::Base
    
    def self.version
      VERSION.join('.')
    end
    
    def time?
      get('/time')[:body]
    end
    
  end
  
end
