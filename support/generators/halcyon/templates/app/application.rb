class Application < Halcyon::Controller
  
  # Summary of available services
  # 
  # This method is just a sample and can be removed altogether. It may be
  # advised to advertise available functionality for public-facing applications
  # to clarify usage.
  # 
  # Returns [{:path=>String:path,Symbol:method=>[Hash:params, *:sample],...},...]
  def index
    ok([
      {
        :path => "/time",
        :GET => [{}, Time.now.to_s],
        :POST => [{:format => "strftime compatible"}, Time.now.strftime("%Y-%m-%dT%H:%M%:%S%Z")]
      },
      {
        :path => "/",
        :GET => [{}, "[{:path=>String:path,Symbol:method=>[Hash:params, *:sample],...},...]"]
      }
    ])
  end
  
  # Responds with the current time in either generic or specific formats
  # 
  # GET
  #   returns the current time
  # POST
  #   returns the current time formatted acccording to +format+
  # 
  # Returns String:time
  def time
    case method
    when :get
      ok(Time.now.to_s)
    when :post
      ok(Time.now.strftime(post[:format] || "%Y-%m-%dT%H:%M%:%S%Z"))
    else
      raise NotImplemented.new
    end
  end
  
end
