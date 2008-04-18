# = Required Libraries
# 
# Specify required libraries specific to the operation of your application.
# 
# Examples
#   %(digest/md5 tempfile date).each{|dep|require dep}
# 
# RubyGems should already be required by Halcyon, so don't include it.

%w(lib/guesser).each{|dep|require dep}
