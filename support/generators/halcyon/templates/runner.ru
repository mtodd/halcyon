require 'halcyon'

puts "(Starting in #{Halcyon.root})"

Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
Thin::Logging.silent = true if defined? Thin

run Halcyon::Runner.new
