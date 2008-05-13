# = Database
# 
# Load the database configuration for the current environment.

Halcyon.db = Halcyon::Runner.load_config(Halcyon::Runner.config_path('database'))
Halcyon.db = Halcyon.db[(Halcyon.environment || :development).to_sym]
