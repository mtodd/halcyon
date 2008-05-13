%w(rubygems halcyon).each{|dep|require dep}

module WeeDB
  
  # = Client
  # 
  # The client interface for accessing services provided by the Halcyon
  # application as defined in the controllers in <tt>app/</tt>.
  # 
  # == Usage
  # 
  # To use the Client in your application, create an instance and call methods
  # defined here. For example:
  # 
  #   client = Weedb::Client.new('http://localhost:4647/')
  #   client.time #=> "Tue Apr 15 21:04:15 -0400 2008"
  # 
  # You can just as easily call the primary <tt>get</tt>, <tt>post</tt>,
  # <tt>put</tt>, and <tt>delete</tt> methods as well, passing in the +path+
  # and any params. For example:
  # 
  #   client.get('/time') #=> "Tue Apr 15 21:04:15 -0400 2008"
  # 
  # By default, if you enter a bad (non-existent) path or the application
  # raises an exception and cannot complete successfully, the standard response
  # format will be returned but with more appropriate +status+ and +body+
  # values. For instance:
  # 
  #   client.get('/nonexistent/path') #=> {:status=>404,:body=>"Not Found"}
  # 
  # Exceptions can be raised on any +status+ returned other than +200+ if you
  # set <tt>Halcyon::Client#raise_exceptions!</tt> to +true+ (which is the
  # default param).
  # 
  #   client.raise_exceptions! #=> true
  #   client.get('/nonexistent/path') #=> NotFound exception is raised
  # 
  # These exceptions all inherit from <tt>Halcyon::Exceptions::Base</tt> so
  # <tt>rescue</tt>ing just normal Halcyon errors is trivial.
  # 
  # However, setting this value can cause the meaning and the appropriate
  # error-handling measures put in place in actions. Although each method
  # could just as easily set the +raise_exceptions+ configuration option
  # itself, it is not advised to do so due to the possibility of non-
  # consistent and confusing behavior it can cause.
  # 
  # If raising exceptions is preferred, it should be set as soon as the
  # client is created and the client methods should be designed accordingly.
  class Client < Halcyon::Client
    
    def self.version
      VERSION.join('.')
    end
    
    # Send data to the WeeDB
    #   +data+ the data to save
    # 
    # Examples
    #   client.push({'foo'=>'bar'}) #=> '1aB2'
    # 
    # Returns String:record_id
    # 
    def push(data)
      if (response = post('/records', :data => data.to_json))[:status] == 200
        response[:body]
      else
        # failure; return all response data for individual attention
        response
      end
    end
    alias_method :store, :push
    
    # Alias for <tt>push</tt>.
    # 
    # Examples
    #   client << {'key' => 'value'} #=> '2bC3'
    # 
    def <<(data)
      push(data)
    end
    
    # Retrieve the data from the WeeDB
    #   +key+ the ID the data is saved under
    # 
    # Examples
    #   client.retrieve('1aB2') #=> {'foo'=>'bar'}
    # 
    # Returns *:data
    # 
    def pull(key)
      if (response = get("/records/#{key}"))[:status] == 200
        response[:body]
      else
        # failure; return all response data for individual attention
        response
      end
    end
    alias_method :retrieve, :pull
    
    # Alias for <tt>pull</tt>.
    # 
    # Examples
    #   client['2bC3'] #=> {'key' => 'value'}
    # 
    def [](key)
      pull(key)
    end
    
  end
  
end
