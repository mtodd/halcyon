# = Environment
# 
# Sets the environment unless already set.
# 
# Creates the <tt>Halcyon.environment</tt> configurable attribute. Since this
# is mapped to <tt>Halcyon.config[:environment]</tt>, environment can be set
# by setting the <tt>environment:</tt> configuration value in the
# <tt>config/config.yml</tt> file.

Halcyon.configurable_attr(:environment)
Halcyon.environment = :development unless Halcyon.environment
