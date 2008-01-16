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
        # scheme is being used, and the credentials pass the
        # +basic_authentication+ test. If any of these fail, an Unauthorized
        # exception is raised (except for non-Basic schemes), otherwise the
        # +route+ is +run+ normally.
        def run(route)
          # make sure there's an authorization header
          raise Base::Exceptions::Unauthorized.new unless !authorization_key.nil?
          
          # make sure the request is via the Basic protocol
          scheme = @env[authorization_key].split.first.downcase.to_sym
          raise Base::Exceptions::BadRequest.new unless scheme == :basic
          
          # make sure the credentials pass the test
          credentials = @env[authorization_key].split.last.unpack("m*").first.split(/:/, 2)
          raise Base::Exceptions::Unauthorized.new unless basic_authentication(*credentials)
          
          # success, so run the route normally
          _run(route)
        rescue Halcyon::Exceptions::Base => e
          @logger.warn "#{uri} => #{e.error}"
          # handles all content error exceptions
          @res.status = e.status
          {:status => e.status, :body => e.error}
        end
        
      end
      
    end
  end
end
