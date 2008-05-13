# = Required Libraries
# 
# Specify required libraries specific to the operation of your application.
# 
# Examples
#   %(digest/md5 tempfile date).each{|dep|require dep}
# 
# RubyGems should already be required by Halcyon, so don't include it.

%w(weedb sequel digest/md5).each{|dep|require dep}

# JSON is also another requirement, but Halcyon already handles the complexity
# of loading the appropriate JSON Gem.
