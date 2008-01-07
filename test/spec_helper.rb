require 'halcyon/server'
require 'rack/mock'

$test = true

class Specr < Halcyon::Server::Base
  
  route do |r|
    r.match('/hello/:name').to(:action => 'greeter')
    r.match('/').to(:action => 'index', :arbitrary => 'random')
  end
  
  def index(params)
    ok('Found')
  end
  
  def greeter(params)
    ok("Hello #{params[:name]}")
  end
  
end
