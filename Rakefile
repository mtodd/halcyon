# Rakefile for Rack.  -*-ruby-*-
require 'rake/rdoctask'
require 'rake/testtask'
require 'lib/halcyon'

desc "Run all the tests"
task :default => [:test]

desc "Do predistribution stuff"
task :predist => [:chmod, :changelog, :rdoc]


desc "Make an archive as .tar.gz"
task :dist => :fulltest do
  sh "export DARCS_REPO=#{File.expand_path "."}; " +
     "darcs dist -d rack-#{get_darcs_tree_version}"
end

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

desc "Run all the fast tests"
task :test do
  sh "specrb -Ilib:test -w #{ENV['TEST'] || '-a'} #{ENV['TESTOPTS']}"
  # sh "specrb -Ilib:test -w #{ENV['TEST'] || '-a'} #{ENV['TESTOPTS'] || '-t "^(?!Rack::Handler|Rack::Adapter)"'}"
end

desc "Run all the tests"
task :fulltest do
  sh "specrb -Ilib:test -w #{ENV['TEST'] || '-a'} #{ENV['TESTOPTS']}"
end

begin
  $" << "sources"  if defined? FromSrc
  require 'rubygems'

  require 'rake'
  require 'rake/clean'
  require 'rake/packagetask'
  require 'rake/gempackagetask'
  require 'fileutils'
rescue LoadError
  # Too bad.
else
  spec = Gem::Specification.new do |s|
    s.name            = "halcyon"
    s.version         = Halcyon.version
    s.platform        = Gem::Platform::RUBY
    s.summary         = "JSON Web Server Framework"

    s.description = <<-EOF
A JSON Web Server Framework designed to provide for simple applications
dealing solely with JSON requests and responses from AJAX client
applications or for lightweight server-side message transport.

Also see http://halcyon.rubyforge.org.
    EOF

    s.files           = manifest + %w()
    s.bindir          = 'bin'
    s.executables     << 'halcyon'
    s.require_path    = 'lib'
    s.has_rdoc        = true
    s.extra_rdoc_files = ['README']
    s.test_files      = Dir['test/{test,spec}_*.rb']

    s.author          = 'Matt Todd'
    s.email           = 'chiology@gmail.com'
    s.homepage        = 'http://halcyon.rubyforge.org'
    s.rubyforge_project = 'halcyon'
  end

  Rake::GemPackageTask.new(spec) do |p|
    p.gem_spec = spec
    p.need_tar = false
    p.need_zip = false
  end
end

desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README' <<
    '--title' << 'Rack Documentation' <<
    '--charset' << 'utf-8'
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include 'README'
  rdoc.rdoc_files.include('lib/rack.rb')
  rdoc.rdoc_files.include('lib/rack/*.rb')
  rdoc.rdoc_files.include('lib/rack/*/*.rb')
end
# task :rdoc => ["SPEC", "RDOX"]

task :pushsite => [:rdoc] do
  sh "rsync -avz doc/ mtodd@halcyon.rubyforge.org:/var/www/gforge-projects/halcyon/doc/"
  sh "rsync -avz site/ mtodd@halcyon.rubyforge.org:/var/www/gforge-projects/halcyon/"
end

begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/{spec,test}_*.rb']
    t.verbose = true     # uncomment to see the executed command
    t.rcov_opts = ["--text-report",
                   "-Ilib:test",
                   "--include-file", "^lib,^test",
                   "--exclude-only", "^/usr,^/home/.*/src,active_"]
  end
rescue LoadError
end
