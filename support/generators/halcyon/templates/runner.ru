require 'halcyon'

$:.unshift(Halcyon.root/'lib')

puts "(Starting in #{Halcyon.root})"

Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
Thin::Logging.silent = true if defined? Thin

run Halcyon::Runner.new
