describe "Halcyon::Config" do
  
  before do
    Halcyon.config = Halcyon::Config.new(:environment => :test)
    # @log = ''
    # @logger = Logger.new(StringIO.new(@log))
    # @config = $config.dup
    # @config[:logger] = @logger
    # @config[:app] = 'Specs'
    # Halcyon.config = @config
    # @app = Halcyon::Runner.new
  end
  
  it "should provide the path of the application root directory" do
    Halcyon.root.should == Dir.pwd
    Halcyon.config[:root] = Dir.pwd
    Halcyon.root.should == Halcyon.config[:root]
  end
  
  it "should provide numerous ways to retrieve configuration values" do
    Halcyon.config[:foo] = :bar
    
    Halcyon.config[:foo].should == :bar
    Halcyon.config.foo.should == :bar
    Halcyon.config.get(:foo).should == :bar
    Halcyon.config.use {|c| c[:foo].should == :bar }
  end
  
  it "should provide numerous ways to set configuration values" do
    Halcyon.config[:foo] = :a; Halcyon.config[:foo].should == :a
    Halcyon.config.foo = :b; Halcyon.config[:foo].should == :b
    Halcyon.config.put(:foo, :c); Halcyon.config[:foo].should == :c
    Halcyon.config.put(:foo => :d); Halcyon.config[:foo].should == :d
    Halcyon.config.use {|c| c[:foo] = :e }; Halcyon.config[:foo].should == :e
  end
  
  it "should access to major config values through Halcyon.<attr> accessors" do
    Halcyon.config.use do |c|
      c[:app] = "Specr"
      c[:root] = Dir.pwd
      c[:paths] = Halcyon::Config::Paths.new
      c[:db] = Mash.new(:test => Mash.new)
      c[:environment] = :test
    end
    
    Halcyon.app.should == Halcyon.config[:app]
    Halcyon.root.should == (Halcyon.config[:root] || Dir.pwd)
    Halcyon.paths.should == Halcyon.config[:paths]
    Halcyon.db.should == Halcyon.config[:db]
    Halcyon.environment.should == Halcyon.config[:environment]
  end
  
  it "should provide custom Halcyon.<attr> accessors interfacing config values" do
    Halcyon.configurable_attr(:foo)
    Halcyon.foo = true
    Halcyon.foo.should == Halcyon.config[:foo]
    
    Halcyon.configurable_reader(:bar) do
      Halcyon.config[:bar].to_sym
    end
    Halcyon.config[:bar] = "foo"
    Halcyon.bar.should == :foo
    
    Halcyon.configurable_reader(:baz, "Halcyon.config[%s].to_sym")
    Halcyon.config[:baz] = "bar"
    Halcyon.baz.should == :bar
    
    Halcyon.configurable_writer(:bing) do |value|
      Halcyon.config[:bing] = value.to_sym
    end
    Halcyon.bing = "foo"
    Halcyon.config[:bing].should == :foo
    
    Halcyon.configurable_writer(:bong, "Halcyon.config[%s] = value.to_sym")
    Halcyon.bong = "bar"
    Halcyon.config[:bong].should == :bar
  end
  
  # it "should ..." do
  #   #
  # end
  
end

describe "Halcyon::Config::Paths" do
  
  before do
    @paths = Halcyon::Config::Paths.new
  end
  
  it "should be able to look up paths by name" do
    @paths.for(:config).should == Halcyon.root/'config'
  end
  
  it "should be able to define new paths" do
    @paths.define(:foo => Halcyon.root/'bar', :bar => Halcyon.root/'foo')
    @paths.for(:foo).should == Halcyon.root/'bar'
    @paths.for(:bar).should == Halcyon.root/'foo'
  end
  
  it "should be able to define new paths by name" do
    @paths.define(:foo, Halcyon.root/'baz')
    @paths.for(:foo).should == Halcyon.root/'baz'
  end
  
  it "should provide a shortcut to look up paths by name" do
    @paths[:config].should == @paths.for(:config)
  end
  
  it "should provide a shortcut to define new paths by name" do
    @paths[:config] = Halcyon.root/'gifnoc'
    @paths.for(:config).should == Halcyon.root/'gifnoc'
  end
  
  it "should raise an ArgumentError if a nonexistent path is queried for" do
    should.raise(ArgumentError) { @paths.for(:nonexistent_path) }
  end
  
end

require 'tmpdir'
require 'yaml'
describe "Halcyon::Config::File" do
  
  before do
    @config = {
      :allow_from => "all",
      :logging => {
        :type => "Logger",
        :level => "debug"
      },
      :root => Dir.pwd,
      :app => "Specr",
      :environment => "development"
    }.to_mash
    File.open(Dir.tmpdir/'config.yaml', 'w+'){|f| f << @config.to_yaml }
    File.open(Dir.tmpdir/'config.json', 'w+'){|f| f << @config.to_json }
  end
  
  it "should load the configuration from the YAML config file" do
    Halcyon::Config::File.new(Dir.tmpdir/'config.yaml').to_hash.should == @config
  end
  
  it "should load the configuration from the JSON config file" do
    Halcyon::Config::File.new(Dir.tmpdir/'config.json').to_hash(:from_json).should == @config
  end
  
  it "should provide shortcuts for loading configuration files" do
    Halcyon::Config::File.load(Dir.tmpdir/'config.yaml').should == @config
    Halcyon::Config::File.load_from_json(Dir.tmpdir/'config.json')
  end
  
  it "should throw an ArgumentError when the config file doesn't exist" do
    should.raise(ArgumentError) { Halcyon::Config::File.load('/path/to/nonexistent/file.yalm') }
  end
  
end
