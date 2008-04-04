require File.join(File.dirname(__FILE__), '..', 'lib', 'halcyon')
require 'rack/mock'

# Default Settings

$config = {
  :allow_from => :all,
  :logger => nil,
  :logging => {
    :level => 'debug'
  }
}

# Default Application

class Application < Halcyon::Controller; end
class Specs < Application
  
  def greeter
    ok("Hello #{params[:name]}")
  end
  
  def index
    ok('Found')
  end
  
  def cause_exception
    raise Exception.new("Oops!")
  end
  
end

class Halcyon::Application
  route do |r|
    r.match('/hello/:name').to(:controller => 'specs', :action => 'greeter')
    r.match('/:action').to(:controller => 'specs')
    r.match('/:controller/:action').to()
    r.match('/').to(:controller => 'specs', :action => 'index', :arbitrary => 'random')
    # r.default_routes
    {:action => 'missing'}
  end
  startup do |config|
    $started = true
  end
end
