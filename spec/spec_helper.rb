require File.join(File.dirname(__FILE__), '..', 'lib', 'halcyon')
require 'rack/mock'
require 'logger'

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
  
  def call_nonexistent_method
    hash = Hash.new
    hash.please_dont_exist_and_please_throw_no_method_error
    ok
  end
  
  private
  
  def undispatchable_private_method
    "it's private, so it won't be found by the dispatcher"
  end
  
end

class Resources < Application

  def index
    ok('List of resources')
  end

  def show
    ok("One resource: #{params[:id]}")
  end
end

class Model
  attr_accessor :id
end

class Halcyon::Application
  route do |r|
    r.resources :resources

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
