#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

#--
# module
#++

module Halcyon
  class Client
    
    # = Reverse Routing
    # 
    # Handles URL generation from route params and action names to complement
    # the routing ability in the Server.
    # 
    # == Usage
    # 
    #   class Simple < Halcyon::Client::Base
    #     route do |r|
    #       r.match('/path/to/match').to(:action => 'do_stuff')
    #       {:action => 'not_found'} # the default route
    #     end
    #     def greet(name)
    #       get(url_for(__method__, :name => name))
    #     end
    #   end
    # 
    # == Default Routes
    # 
    # The default route is selected if and only if no other routes matched the
    # action and params supplied as a fallback query to supply. This should
    # generate an error in most cases, unless you plan to handle this exception
    # specifically.
    class Router
      
      # Retrieves the last value from the +route+ call in Halcyon::Client::Base
      # and, if it's a Hash, sets it to +@@default_route+ to designate the
      # failover route. If +route+ is not a Hash, though, the internal default
      # should be used instead (as the last returned value is probably a Route
      # object returned by the +r.match().to()+ call).
      # 
      # Used exclusively internally.
      def self.default_to route
        @@default_route = route.is_a?(Hash) ? route : {:action => 'not_found'}
      end
      
      # This method performs the param matching and URL generation based on the
      # inputs from the +url_for+ method. (Caution: not for the feint hearted.)
      def self.route(action, params)
        r = nil
        @@routes.each do |r|
          path, pars = r
          if pars[:action] == action
            # if the actions match up (a pretty good sign of success), make sure the params match up
            if (!pars.empty? && !params.empty? && (/(:#{params.keys.first})/ =~ path).nil?) ||
              ((pars.empty? && !params.empty?) || (!pars.empty? && params.empty?))
              r = nil
              next
            else
              break
            end
          end
        end
        
        # make sure a route is returned even if no match is found
        if r.nil?
          #return default route
          @@default_route
        else
          # params (including action and module if set) for the matching route
          path = r[0].dup
          # replace all params with the proper placeholder in the path
          params.each{|p| path.gsub!(/:#{p[0]}/, p[1]) }
          path
        end
      end
      
      #--
      # Route building methods
      #++
      
      # Sets up the +@@routes+ hash and begins the processing by yielding to the block.
      def self.prepare
        @@path = nil
        @@routes = {}
        yield self if block_given?
      end
      
      # Stores the path temporarily in order to put it in the hash table.
      def self.match(path)
        @@path = path
        self
      end
      
      # Adds the final route to the hash table and clears the temporary value.
      def self.to(params={})
        @@routes[@@path] = params
        @@path = nil
        self
      end
      
    end
  end
end
