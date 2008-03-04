#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

#--
# dependencies
#++

begin
  %w(rubygems merb/core_ext merb/router uri).each {|dep|require dep}
rescue LoadError => e
  abort "Merb must be installed for Routing to function. Please install Merb."
end

#--
# module
#++

module Halcyon
  class Application
    
    # = Routing
    # 
    # Handles routing.
    # 
    # == Usage
    # 
    #   class Xy < Halcyon::Server::Base
    #     route do |r|
    #       r.match('/path/to/match').to(:action => 'do_stuff')
    #       {:action => 'not_found'} # the default route
    #     end
    #     def do_stuff(params)
    #       [200, {}, 'OK']
    #     end
    #   end
    # 
    # == Default Routes
    # 
    # Supplying a default route if none of the others match is good practice,
    # but is unnecessary as the predefined route is always, automatically,
    # going to contain a redirection to the +not_found+ method which already
    # exists in Halcyon::Server::Base. This method is freely overwritable, and
    # is recommended for those that wish to handle unroutable requests
    # themselves.
    # 
    # In order to set a different default route, simply end the call to +route+
    # with a hash containing the action (and optionally the module) to run.
    # 
    # == The Hard Work
    # 
    # The mechanics of the router are solely from the efforts of the Merb
    # community. This functionality is completely ripped right out of Merb
    # and makes it functional. All credit to them, and be sure to check out
    # their great framework: if Halcyon isn't quite what you need, maybe Merb
    # is.
    # 
    # http://merbivore.com/
    class Router < Merb::Router
      
      # Retrieves the last value from the +route+ call in Halcyon::Server::Base
      # and, if it's a Hash, sets it to +@@default_route+ to designate the
      # failover route. If +route+ is not a Hash, though, the internal default
      # should be used instead (as the last returned value is probably a Route
      # object returned by the +r.match().to()+ call).
      # 
      # Used exclusively internally.
      def self.default_to route
        @@default_route = route.is_a?(Hash) ? route : {:action => 'not_found'}
      end
      
      # Called internally by the Halcyon::Server::Base#call method to match
      # the current request against the currently defined routes. Returns the
      # params list defined in the +to+ routing definition, opting for the
      # default route if no match is made.
      def self.route(env)
        # pull out the path requested (WEBrick keeps the host and port and protocol in REQUEST_URI)
        # PATH_INFO is failover if REQUEST_URI is blank (like what Rack::MockRequest does)
        uri = URI.parse(env['REQUEST_URI'] || env['PATH_INFO']).path
        
        # prepare request
        path = (uri ? uri.split('?').first : '').sub(/\/+/, '/')
        path = path[0..-2] if (path[-1] == ?/) && path.size > 1
        req = Struct.new(:path, :method).new(path, env['REQUEST_METHOD'].downcase.to_sym)
        
        # perform match
        route = self.match(req, {})
        
        # make sure a route is returned even if no match is found
        if route[0].nil?
          #return default route
          env['halcyon.logger'].debug "No route found. Using default." if env['halcyon.logger'].is_a? Logger
          @@default_route
        else
          # params (including action and module if set) for the matching route
          route[1]
        end
      end
      
    end
  end
end
