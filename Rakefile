$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "lib")))

%w(rubygems rake rake/clean rake/packagetask rake/gempackagetask rake/rdoctask rake/contrib/rubyforgepublisher fileutils pp).each{|dep|require dep}

include FileUtils

require 'lib/halcyon'

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
    --title "Halcyon\ documentation"
    --exclude "^(_darcs|spec|pkg)/"
  ]
}

BASEDIR = File.expand_path(File.dirname(__FILE__))

spec = Gem::Specification.new do |s|
  s.name = project[:name]
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
  s.add_dependency('rack', '>=0.2.0')
  s.add_dependency('json', '>=1.1.1')
  s.add_dependency('merb', '>=0.4.1')
  s.required_ruby_version = '>= 1.8.6'
  s.files = (project[:rdoc_files] + %w[Rakefile] + Dir["{spec,lib}/**/*"]).uniq
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

task 'run-spec' do
  require 'spec'
  $:.unshift(File.dirname(__FILE__))
  stdout = []
  class << stdout
    def print(*e) concat(e); Kernel.print(*e); end
    def puts(*e) concat(e); Kernel.puts(*e); end
    def flush; end
  end
  stderr = []
  class << stderr
    alias print <<
    def print(*e) concat(e); Kernel.print(*e); end
    def puts(*e) concat(e); Kernel.puts(*e); end
    def flush; end
  end
  ::Spec::Runner::CommandLine.run(['spec'], stderr, stdout, false, true)
  exit_status = stdout.last.strip[/(\d+) failures?/, 1].to_i
  at_exit{
    exit(exit_status == 0 ? 0 : 1)
  }
end

desc "run rspec"
task :spec do
  run = Rake::Task['run-spec']
  run.execute
end

task :default => :spec

desc "Do predistribution stuff"
task :predist => [:chmod, :changelog, :rdoc]

def manifest
  `darcs query manifest`.split("\n").map { |f| f.gsub(/\A\.\//, '') }
end

desc "Make binaries executable"
task :chmod do
  Dir["bin/*"].each { |binary| File.chmod(0775, binary) }
  Dir["test/cgi/test*"].each { |binary| File.chmod(0775, binary) }
end

desc "Generate a ChangeLog"
task :changelog do
  sh "svn log >ChangeLog"
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
