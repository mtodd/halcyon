#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

#--
# dependencies
#++

begin
  %w(rubygems merb/core_ext merb/router).each {|dep|require dep}
rescue LoadError => e
  abort "Merb must be installed for Routing to function. Please install Merb."
end

#--
# module
#++

module Halcyon
  class Server
    
    # Handles routing.
    # 
    # = Usage
    # 
    #   class Xy < Halcyon::Server::Base
    #     route do |r|
    #       r.match('/path/to/match').to(:action => 'do_stuff')
    #       {:action => 'not_found'}
    #     end
    #     def do_stuff(params)
    #       [200, {}, 'OK']
    #     end
    #   end
    # 
    # = The Hard Work
    # 
    # The mechanics of the router are solely from the efforts of the Merb
    # community. This functionality is completely ripped right out of Merb
    # and makes it functional.
    class Router < Merb::Router
      def self.default_to route
        @@default_route = route
      end
      def self.route(env)
        uri = env['REQUEST_URI']
        
        # prepare request
        path = (uri ? uri.split('?').first : '').sub(/\/+/, '/')
        path = path[0..-2] if (path[-1] == ?/) && path.size > 1
        req = Struct.new(:path, :method).new(path, env['REQUEST_METHOD'].downcase.to_sym)
        
        # perform match
        route = self.match(req, {})
        
        # make sure a route is returned even if no match is found
        if route[0].nil?
          #return default route
          @@default_route
        else
          route[1]
        end
      end
    end
  end
end
