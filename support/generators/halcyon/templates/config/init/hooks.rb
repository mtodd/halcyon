# = Hooks
#
# Specify actions to run at specific times during the application's execution,
# such as the startup or shutdown events.
# 
# Available Hooks
#   +startup+
#   +shutdown+
# 
# All hooks take the current application configuration as its sole block param.
# 
# Examples
#   Halcyon::Application.startup do |config|
#     # Halcyon.db set in config/initialize/database.rb
#     ::DB = Sequel(Halcyon.db)
#     logger.info "Connected to database"
#   end
# 
# The +logger+ object is available to log messages on status or otherwise.

# = Startup
# 
# Run when the Halcyon::Application object is instanciated, after all
# initializers are loaded.
# 
# Ideal for establishing connections to resources like databases.
# Establish configuration options in initializer files, though.
Halcyon::Application.startup do |config|
  logger.info 'Define startup tasks in config/init/hooks.rb'
end

# = Shutdown
# 
# Run <tt>at_exit</tt>. Should run in most cases of termination.
# 
# Ideal for closing connections to resources.
Halcyon::Application.shutdown do |config|
  logger.info 'Define shutdown tasks in config/init/hooks.rb'
end
