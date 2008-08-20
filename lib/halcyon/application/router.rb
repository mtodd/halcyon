%w(rubygems extlib merb-core/dispatch/router uri).each {|dep|require dep}

module Halcyon
  class Application
    
    # = Routing
    # 
    # Handles routing.
    # 
    # == Usage
    # 
    #   class Halcyon::Application
    #     route do |r|
    #       r.match('/path/to/match').to(:controller => 'a', :action => 'b')
    #       {:action => 'not_found'} # the default route
    #     end
    #   end
    # 
    # == Default Routes
    # 
    # Supplying a default route if none of the others match is good practice,
    # but is unnecessary as the predefined route is always, automatically,
    # going to contain a redirection to the +not_found+ method which already
    # exists in Halcyon::Controller. This method is freely overwritable, and
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
      
      class << self
        
        # Retrieves the last value from the +route+ call in Halcyon::Controller
        # and, if it's a Hash, sets it to +@@default_route+ to designate the
        # failover route. If +route+ is not a Hash, though, the internal default
        # should be used instead (as the last returned value is probably a Route
        # object returned by the +r.match().to()+ call).
        #   +route+ the default route, or nothing to use <tt>not_found</tt>
        # 
        # Used exclusively internally.
        # 
        # Returns nothing
        def default_to(route)
          @@default_route = route.is_a?(Hash) ? route : {:action => 'not_found'}
        end
        
        # Called internally by the Halcyon::Controller#call method to match
        # the current request against the currently defined routes. Returns the
        # params list defined in the +to+ routing definition, opting for the
        # default route if no match is made.
        #   +request+ the request object to route against
        # 
        # Returns Hash:{:controller=>..., :action=>..., ...}
        def route(request)
          req = Struct.new(:path, :method, :params).new(request.path_info, request.request_method.downcase.to_sym, request.params)
          
          # perform match
          route = self.match(req)
          
          # make sure a route is returned even if no match is found
          if route[0].nil?
            #return default route
            self.logger.debug "No route found. Using default."
            @@default_route
          else
            # params (including action and module if set) for the matching route
            route[1]
          end
        end
        
      end
      
    end
  end
end
