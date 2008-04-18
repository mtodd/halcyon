require 'halcyon'

$:.unshift(Halcyon.root/'lib')
puts "(Starting in #{Halcyon.root})"
Thin::Logging.silent = true if defined? Thin

# = Apps
# The applications to try.
apps = []

# = Redirecter
# Requests to <tt>/</tt> get redirected to <tt>/index.html</tt>.
apps << lambda do |env|
  case env['PATH_INFO']
  when '/'
    puts " ~ Redirecting to /index.html"
    [302, {'Location' => '/index.html'}, ""]
  else
    [404, {}, ""]
  end
end

# = Static Server
# Make sure that the static resources are accessible from the same address so
# we don't have to worry about the Same Origin stuff.
apps << Rack::File.new(Halcyon.root/'static')

# = Halcyon App
apps << Halcyon::Runner.new

# = Server
# Run the Cascading server
run Rack::Cascade.new(apps)
