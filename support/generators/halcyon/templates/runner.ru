require 'halcyon'

$:.unshift(Halcyon.root/'lib')

puts "(Starting in #{Halcyon.root})"

Thin::Logging.silent = true if defined? Thin

# Uncomment if you plan to allow clients to send requests with the POST body
# Content-Type as application/json.
# use Rack::PostBodyContentTypeParsers

run Halcyon::Runner.new
