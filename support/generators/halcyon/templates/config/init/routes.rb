# = Routes
# 
# Halcyon::Application::Router is the request routing mapper for the merb
# framework.
# 
# You can route a specific URL to a controller / action pair:
# 
#   r.match("/contact").
#     to(:controller => "info", :action => "contact")
# 
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
# 
#   r.match("/books/:book_id/:action").
#     to(:controller => "books")
# 
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
# 
#   r.match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
# 
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.
# 
# Stolen directly from generated Merb app. All documentation applies.
# Read more about the Merb router at http://merbivore.com/.
Halcyon::Application.route do |r|
  
  # Sample route for the sample functionality in Application.
  # Safe to remove!
  r.match('/time').to(:controller => 'application', :action => 'time')
  
  # RESTful routes
  # r.resources :posts

  # This is the default route for /:controller/:action/:id
  # This is fine for most cases.  If you're heavily using resource-based
  # routes, you may want to comment/remove this line to prevent
  # clients from calling your create or destroy actions with a GET
  r.default_routes
  
  # Change this for the default route to be available at /
  r.match('/').to(:controller => 'application', :action => 'index')
  # It can often be useful to respond with available functionality if the
  # application is a public-facing service.
  
  # Default not-found route
  {:action => 'not_found'}
  
end
