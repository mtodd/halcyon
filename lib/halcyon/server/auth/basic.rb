#!/usr/bin/env ruby
#--
#  Created by Matt Todd on 2008-01-16.
#  Copyright (c) 2008. All rights reserved.
#++

#--
# module
#++

module Halcyon
  class Server
    module Auth
      
      # = Introduction
      # 
      # The Auth::Basic class provides an alternative to the Server::Base
      # class for creating servers with HTTP Basic Authentication built in.
      # 
      # == Usage
      # 
      # In order to provide for HTTP Basic Authentication in your server,
      # it would first need to inherit from this class instead of Server::Base
      # and then provide a method to check for the existence of the credentials
      # and respond accordingly. This looks like the following:
      # 
      #   class AuthenticatedApp < Halcyon::Server::Auth::Basic
      #     def basic_authorization(username, password)
      #       [username, password] == ['rupert', 'secret']
      #     end
      #     # write normal Halcyon server app here
      #   end
      # 
      # The credentials passed to the +basic_authorization+ method are pulled
      # from the appropriate Authorization header value and parsed from the
      # base64 values. If no Authorization header value is passed, an exception
      # is thrown resulting in the appropriate response to the client.
      class Basic < Server::Base
        
        AUTHORIZATION_KEYS = ['HTTP_AUTHORIZATION', 'X-HTTP_AUTHORIZATION', 'X_HTTP_AUTHORIZATION']
        
        # Determines the appropriate HTTP Authorization header to refer to when
        # plucking out the header for processing.
        def authorization_key
          @authorization_key ||= AUTHORIZATION_KEYS.detect{|k|@env.has_key?(k)}
        end
        
        alias :_run :run
        
        # Ensures that the HTTP Authentication header is included, the Basic
        # scheme is being used, and the credentials pass the +basic_auth+
        # test. If any of these fail, an Unauthorized exception is raised
        # (except for non-Basic schemes), otherwise the +route+ is +run+
        # normally.
        # 
        # See the documentation for the +basic_auth+ class method for details
        # concerning the credentials and action inclusion/exclusion.
        def run(route)
          # test credentials if the action is one specified to be tested
          if ((@@auth[:except].nil? && @@auth[:only].nil?) || # the default is to test if no restrictions
            (!@@auth[:only].nil? && @@auth[:only].include?(route[:action].to_sym)) || # but if the action is in the :only directive, test
            (!@@auth[:except].nil? && !@@auth[:except].include?(route[:action].to_sym))) # or if the action is not in the :except directive, test
            
            # make sure there's an authorization header
            raise Base::Exceptions::Unauthorized.new unless !authorization_key.nil?
            
            # make sure the request is via the Basic protocol
            scheme = @env[authorization_key].split.first.downcase.to_sym
            raise Base::Exceptions::BadRequest.new unless scheme == :basic
            
            # make sure the credentials pass the test
            credentials = @env[authorization_key].split.last.unpack("m*").first.split(':', 2)
            raise Base::Exceptions::Unauthorized.new unless @@auth[:method].call(*credentials)
          end
          
          # success, so run the route normally
          _run(route)
        rescue Halcyon::Exceptions::Base => e
          @logger.warn "#{uri} => #{e.error}"
          # handles all content error exceptions
          @res.status = e.status
          {:status => e.status, :body => e.error}
        end
        
        # Provides a way to define a test as well as set limits on what is
        # tested for Basic Authorization. This method should be called in the
        # definition of the server. A simple example would look like:
        # 
        #   class Servr < Halcyon::Server::Auth::Basic
        #     basic_auth :only => [:grant] do |user, pass|
        #       # test credentials
        #     end
        #     # routes and actions follow...
        #   end
        # 
        # Two acceptable options include <tt>:only</tt> and <tt>:except</tt>.
        def self.basic_auth(options={}, &proc)
          instance_eval do
            @@auth = options.merge(:method => proc)
          end
        end
        
      end
      
    end
  end
end
