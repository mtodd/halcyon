%w(rubygems rake rake/clean rake/rdoctask fileutils pp halcyon).each{|dep|require dep}

include FileUtils

# Halcyon.root => the root application directory
# Halcyon.app  => the application name

desc "Start the application on port 4647"
task :start do
  sh "halcyon start -p 4647"
end

desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README' <<
    '--title' << "#{Halcyon.app} Documentation" <<
    '--charset' << 'utf-8'
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('app/**/*.rb')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# = Custom Rake Tasks
# 
# Add your custom rake tasks here.

# ...

# = Default Task
task :default => Rake::Task['start']
