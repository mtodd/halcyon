# = Routes
Halcyon::Application.route do |r|
  r.match('/time').to(:controller => 'application', :action => 'time')
  
  r.match('/').to(:controller => 'application', :action => 'index')
  
  # failover
  {:action => 'not_found'}
end
