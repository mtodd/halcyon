require 'halcyon'
require 'app'

puts "(Starting in #{Halcyon.root})"

Thin::Logging.silent = true if defined? Thin

run Halcyon::Runner.new
