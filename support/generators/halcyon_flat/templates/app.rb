require 'halcyon'

# = Required Libraries
%w().each {|dep|require dep}

# = Configuration
Halcyon.config = {
  :allow_from => 'all',
  :logging => {
    :type => 'Logger',
    # :file => nil, # STDOUT
    :level => 'debug'
  }
}.to_mash

# = Initialization
class Halcyon::Application
  startup do |config|
    self.logger.info 'Initialize application resources and define routes in config/initialize.rb'
  end
  # = Routes
  route do |r|
    r.match('/time').to(:controller => 'application', :action => 'time')
    
    r.match('/').to(:controller => 'application', :action => 'index')
    
    # failover
    {:action => 'not_found'}
  end
end

# = Application
class Application < Halcyon::Controller
  
  def index
    ok('Nothing here')
  end
  
  def time
    ok(Time.now.to_s)
  end
  
end
