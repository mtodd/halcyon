%w(rubygems halcyon).each {|dep|require dep}

module Sparrow
  
  class Client < Halcyon::Client
    
    def self.version
      VERSION.join('.')
    end
    
    def time
      get('/time')[:body]
    end
    
  end
  
end
