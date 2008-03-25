# = Required Libraries
%w().each {|dep|require dep}

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
