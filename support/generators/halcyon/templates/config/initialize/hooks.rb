# = Hooks
Halcyon::Application.startup do |config, logger|
  logger.info 'Define startup tasks in config/initialize/hooks.rb'
end

Halcyon::Application.shutdown do |config, logger|
  logger.info 'Define shutdown tasks in config/initialize/hooks.rb'
end
