%w(rubygems halcyon/server).each{|dep|require dep}
class Simple < Halcyon::Server::Base
  route do |r|
    r.match('/user/show/:id').to(:module => 'user', :action => 'show')
    r.match('/show/:id').to(:action => 'show')
    r.match('/hello/:name').to(:action => 'greet')
    r.match('/wink').to(:action => 'wink')
    r.match('/').to(:action => 'index')
    {:action => 'what_are_you_looking_for?'}
  end
  
  def greet
    standard_response("Hello #{params[:name]}!")
  end
  def wink
    ok("I'm winking at you right now.")
  end
  def index
    {:status => 200, :body => 'Wish you were cooler.'}
  end
  
  user do
    def show
      {:status => 200, :body => "You request: #{params[:id]}"}
    end
  end
  
  def show
    {:status => 200, :body => "This method does not conflict with the show method in the user module."}
  end
  
  # custom 404 error handler
  def what_are_you_looking_for?
    raise Exceptions::NotFound.new(404, 'Not Found; You did not find what you were expecting because it is not here. What are you looking for?')
  end
end
Rack::Handler::Mongrel.run Simple.new, :Port => 3801 if __FILE__ == $0
