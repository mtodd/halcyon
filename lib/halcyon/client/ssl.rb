require 'net/https'

module Halcyon
  class Client
    private
    
    # Sets the SSL-specific options for the Server.
    # 
    def prepare_server(serv)
      serv.use_ssl = true if self.uri.scheme == 'https'
    end
    
  end
end
