require 'halcyon/server'
require 'rack/mock'

$test = true

class Specr < Halcyon::Server::Base
  
  route do |r|
    r.match('/hello/:name').to(:action => 'greeter')
    r.match('/').to(:action => 'index', :arbitrary => 'random')
  end
  
  def index
    ok('Found')
  end
  
  def greeter
    ok("Hello #{params[:name]}")
  end
  
end
