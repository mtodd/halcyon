Halcyon.config.use do |c|
  
  # = Framework
  # 
  # <tt>allow_from</tt>: specifies what connections to accept;
  # * <tt>all</tt>: allow connections from all clients
  # * <tt>local</tt>: only allow connections from the same host (localhost et al)
  # * <tt>halcyon_clients</tt>: only Halcyon clients (tests the User-Agent only)
  c[:allow_from] = :all
  
  # = Environment
  # 
  # Uncomment to manually specify the environment to run the application in.
  # Defaults to <tt>:development</tt>.
  # 
  # c[:environment] = :production
  
  # = Logging
  # 
  # Configures the logging client in the framework, including destination,
  # level filter, and what logger to use.
  # 
  # <tt>type</tt>: the logger to use (defaults to Ruby's <tt>Logger</tt>)
  # * <tt>Logger</tt>
  # * <tt>Analogger</tt>
  # * <tt>Logging</tt>
  # * <tt>Log4r</tt>
  # <tt>file</tt>: the log file; leave unset for STDOUT
  # <tt>level</tt>: the message filter level (default to <tt>debug</tt>)
  # * specific to the client used, often is: debug, info, warn, error, fatal
  # = Logging
  c[:logging] = {
    :type => 'Logger',
    # :file => nil, # nil is STDOUT
    :level => 'debug'
  }
  
  # = Application
  # 
  # Your application-specific configuration options here.
  
end
