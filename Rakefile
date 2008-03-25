$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "lib")))

%w(rubygems rake rake/clean rake/packagetask rake/gempackagetask rake/rdoctask rake/contrib/rubyforgepublisher fileutils pp).each{|dep|require dep}

include FileUtils

require 'halcyon'

project = {
  :name => "halcyon",
  :version => Halcyon.version,
  :author => "Matt Todd",
  :email => "chiology@gmail.com",
  :description => "A JSON App Server Framework",
  :homepath => 'http://halcyon.rubyforge.org',
  :bin_files => %w(halcyon),
  :rdoc_files => %w(lib),
  :rdoc_opts => %w[
    --all
    --quiet
    --op rdoc
    --line-numbers
    --inline-source
    --title "Halcyon\ API"
    --exclude "^(_darcs|spec|pkg|.svn)/"
  ],
  :dependencies => {
    'json_pure' => '>=1.1.2',
    'rack' => '>=0.3.0',
    'merb' => '>=0.4.1',
    'rubigen' => '>=1.2.4'
  },
  :requirements => 'install the json gem to get faster JSON parsing',
  :ruby_version_required => '>=1.8.6'
}

BASEDIR = File.expand_path(File.dirname(__FILE__))

spec = Gem::Specification.new do |s|
  s.name = project[:name]
  s.rubyforge_project = project[:name]
  s.version = project[:version]
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = project[:rdoc_files]
  s.rdoc_options += project[:rdoc_opts]
  s.summary = project[:description]
  s.description = project[:description]
  s.author = project[:author]
  s.email = project[:email]
  s.homepage = project[:homepath]
  s.executables = project[:bin_files]
  s.bindir = "bin"
  s.require_path = "lib"
  project[:dependencies].each{|dep|
    s.add_dependency(dep[0], dep[1])
  }
  s.requirements << project[:requirements]
  s.required_ruby_version = project[:ruby_version_required]
  s.files = (project[:rdoc_files] + %w[Rakefile README LICENSE AUTHORS] + Dir["{spec,lib,example,support,clients}/**/*"]).uniq
end

Rake::GemPackageTask.new(spec) do |p|
  p.need_zip = true
  p.need_tar = true
end

desc "Package and Install halcyon"
task :install do
  name = "#{project[:name]}-#{project[:version]}.gem"
  sh %{rake package}
  sh %{sudo gem install pkg/#{name}}
end

desc "Uninstall the halcyon gem"
task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{project[:name]}}
end

namespace 'spec' do
  desc "generate spec"
  task :gen do
    sh "bacon -r~/lib/bacon/output -rlib/halcyon -rtest/spec_helper spec/**/* -s > spec/SPEC"
  end
  
  desc "run rspec"
  task :run do
    sh "bacon -r~/lib/bacon/output -rlib/halcyon -rspec/spec_helper spec/**/* -o CTestUnit"
  end
  
  desc "run rspec verbosely"
  task :verb do
    sh "bacon -r~/lib/bacon/output -rlib/halcyon -rspec/spec_helper spec/**/* -o CSpecDox"
  end
end

desc "Do predistribution stuff"
task :predist => [:chmod, :changelog, :manifest, :rdoc]

def manifest
  require 'find'
  paths = []
  manifest = File.new('MANIFEST', 'w+')
  Find.find('.') do |path|
    path.gsub!(/\A\.\//, '')
    next if path =~ /(\.svn|doc|pkg|^\.|MANIFEST)/
    paths << path
  end
  paths.sort.each do |path|
    manifest.puts path
  end
  manifest.close
end

desc "Make binaries executable"
task :chmod do
  Dir["bin/*"].each { |binary| File.chmod(0775, binary) }
  Dir["test/cgi/test*"].each { |binary| File.chmod(0775, binary) }
end

desc "Generate a MANIFEST"
task :manifest do
  manifest
end

desc "Generate a CHANGELOG"
task :changelog do
  sh "svn log > CHANGELOG"
end

desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README' <<
    '--title' << 'Halcyon Documentation' <<
    '--charset' << 'utf-8'
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include 'README'
  rdoc.rdoc_files.include('lib/halcyon.rb')
  rdoc.rdoc_files.include('lib/halcyon/*.rb')
  rdoc.rdoc_files.include('lib/halcyon/*/*.rb')
end

task :pushsite => [:rdoc] do
  sh "rsync -avz doc/ mtodd@halcyon.rubyforge.org:/var/www/gforge-projects/halcyon/doc/"
  sh "rsync -avz site/ mtodd@halcyon.rubyforge.org:/var/www/gforge-projects/halcyon/"
end

desc "find . -name \"*.rb\" | xargs wc -l | grep total"
task :loc do
  sh "find . -name \"*.rb\" | xargs wc -l | grep total"
end

task :default => Rake::Task['spec:run']
