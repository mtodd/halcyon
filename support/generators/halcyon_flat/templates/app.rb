require 'halcyon'

# = Required Libraries
%w().each {|dep|require dep}

# = Configuration
# Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
Halcyon.config = {
  :allow_from => 'all',
  :logging => {
    :type => 'Logger',
    # :file => nil, # STDOUT
    :level => 'debug'
  }
}.to_mash

# = Routes
Halcyon::Application.route do |r|
  r.match('/time').to(:controller => 'application', :action => 'time')
  
  r.match('/').to(:controller => 'application', :action => 'index')
  
  # failover
  {:action => 'not_found'}
end

# = Hooks
Halcyon::Application.startup do |config, logger|
  logger.info 'Define startup tasks in config/initialize/hooks.rb'
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
