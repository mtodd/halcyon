# $Id$

gem 'haml', '=1.8.2'
require 'haml'

load 'tasks/setup.rb'

task :default => :build

desc 'deploy the site to the webserver'
task :deploy => [:build, 'deploy:rsync']

# EOF

namespace(:site) do
  
  desc 'Update the website'
  task :update => [:build] do
    `rsync -avz ./output/ mtodd@halcyon.rubyforge.org:/var/www/gforge-projects/halcyon/ > /dev/null`
    puts "* uploaded ./output/ to http://halcyon.rubyforge.org/"
  end
  
end
