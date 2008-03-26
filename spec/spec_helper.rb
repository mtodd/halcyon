require File.join(File.dirname(__FILE__), '..', 'lib', 'halcyon')
require 'rack/mock'

class Application < Halcyon::Controller; end
class Primary < Application
  
  def greeter
    ok("Hello #{params[:name]}")
  end
  
  def index
    ok('Found')
  end
  
  def failure
    raise NotFound.new
  end
  
end

class Halcyon::Application
  route do |r|
    r.match('/hello/:name').to(:controller => 'primary', :action => 'greeter')
    r.match('/:action').to(:controller => 'primary')
    r.match('/').to(:controller => 'primary', :action => 'index', :arbitrary => 'random')
    {:action => 'failure'}
  end
  startup do |config|
    $started = true
  end
end
