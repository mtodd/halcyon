require 'halcyon'
require 'rack/mock'

$test = true

class Specr < Halcyon::Application
  
  route do |r|
    r.match('/hello/:name').to(:action => 'greeter')
    r.match('/:action').to()
    r.match('/').to(:action => 'index', :arbitrary => 'random')
  end
  
  def startup
    @started = true
  end
  
  def index
    ok('Found')
  end
  
  def greeter
    ok("Hello #{params[:name]}")
  end
  
  def failure
    raise ArgumentError.new("Halcyon::Application::Testing::ArgumentErrorException")
  end
  
end
