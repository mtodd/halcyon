# Created by elliottcable: elliottcable.name
# Licensed as Creative Commons BY-NC-SA 3.0 (creativecommons.org/licenses/by-nc-sa/3.0)
require 'haml/engine'
require 'sass/engine'

task :default => ['site:update']

namespace(:site) do
  
  desc 'Update the website'
  task :update => ['haml:compile', 'sass:compile'] do
    `rsync -avz ./compiled/ mtodd@halcyon.rubyforge.org:/var/www/gforge-projects/halcyon/ > /dev/null`
    puts "* uploaded ./compiled/ to http://halcyon.rubyforge.org/"
  end
  
end

namespace(:sass) do
  
  desc 'Make compiled/stylesheets/ directory if nonexistent'
  task :mkdir => ['haml:mkdir'] do
    unless File.exist?('./compiled/stylesheets/')
      Dir.mkdir('./compiled/stylesheets/')
      puts "* created ./compiled/stylesheets/"
    end
  end
  
  desc 'Clear compiled CSS files'
  task :clear do
    Dir['./compiled/stylesheets/*.css'].each do |file|
      File.delete file
      puts "* deleted #{File.basename(file)}"
    end
  end
  
  desc 'Compile SASS templates to CSS'
  task :compile => [:mkdir, :clear] do
    style = (ENV['SASS_STYLE'] || 'compressed').to_sym
    Dir['./source/stylesheets/*.sass'].each do |sass_filename|
      File.open(sass_filename, 'r') do |sass_file|
        css_filename = sass_filename.gsub('.sass', '.css').gsub('./source/', './compiled/')
        File.open(css_filename, 'w') do |css_file|
          css_file << Sass::Engine.new(sass_file.read, :style => style, :filename => sass_filename.to_s, :load_paths => ['.']).to_css
          puts "* compiled #{File.basename(css_file.path)}"
        end
      end
    end
  end
  
end

namespace(:haml) do
  
  desc 'Make compiled/ directory if nonexistent'
  task :mkdir do
    unless File.exist?('./compiled/')
      Dir.mkdir('./compiled/')
      puts "* created ./compiled/"
    end
  end
  
  desc 'Clear compiled HTML files'
  task :clear do
    Dir['./compiled/*.html'].each do |file|
      File.delete file
      puts "* deleted #{File.basename(file)}"
    end
  end
  
  desc 'Compile HAML templates to HTML'
  task :compile => [:mkdir, :clear] do
    Dir['./source/*.haml'].each do |haml_filename|
      File.open(haml_filename, 'r') do |haml_file|
        html_filename = haml_filename.gsub('.haml', '.html').gsub('./source/', './compiled/')
        File.open(html_filename, 'w') do |html_file|
          html_file << Haml::Engine.new(haml_file.read, :filename => haml_filename.to_s, :load_paths => ['.']).to_html
          puts "* compiled #{File.basename(html_file.path)}"
        end
      end
    end
  end
  
end

desc 'Clear all compiled files'
task :clear => ['sass:clear', 'haml:clear'] do
  Dir.rmdir('./compiled/stylesheets/')
  puts "* deleted ./compiled/stylesheets/"
  
  Dir.rmdir('./compiled/')
  puts "* deleted ./compiled/"
end

