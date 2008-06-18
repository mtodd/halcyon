describe "Halcyon" do
  
  before do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    Halcyon.config.use do |c|
      c[:logger] = @logger
    end
    @app = Halcyon::Runner.new
  end
  
  it "should provide the path of the application root directory" do
    Halcyon.root.should == Dir.pwd
  end
  
  it "should provide quick access to the configuration hash" do
    Halcyon.config.is_a?(Halcyon::Config).should.be.true?
  end
  
  it "should provide environment label" do
    Halcyon.environment.should == :test
    Halcyon.environment.should == Halcyon.config[:environment]
  end
  
  it "should provide universal access to a logger" do
    # We assume Logger here because, you know, we're gods of the test
    Halcyon.logger.is_a?(Logger).should.be.true?
    # And this is just a side affect of making the logger universally accessible
    {}.logger.is_a?(Logger).should.be.true?
  end
  
  it "should provide the (estimated) application name" do
    # We set this above
    Halcyon.app.should == "Specs"
  end
  
  it "should provide sane default paths for essential components" do
    Halcyon.paths.is_a?(Halcyon::Config::Paths).should.be.true?
    Halcyon.paths[:controller].should == Halcyon.root/"app"
    Halcyon.paths[:model].should == Halcyon.root/"app"/"models"
    Halcyon.paths[:lib].should == Halcyon.root/"lib"
    Halcyon.paths[:config].should == Halcyon.root/"config"
    Halcyon.paths[:init].should == Halcyon.root/"config"/"init"
    Halcyon.paths[:log].should == Halcyon.root/"log"
  end
  
  it "should provide configurable attribute definition for quick access to specific configuration values" do
    test_method = "oracle"
    method_count = Halcyon.methods.length
    Halcyon.configurable("oracle")
    (Halcyon.methods.length - method_count).should == 2
    Halcyon.method(test_method.to_sym).is_a?(Method).should.be.true?
    Halcyon.method("#{test_method}=".to_sym).is_a?(Method).should.be.true?
    Halcyon.send("#{test_method}=".to_sym, 10)
    Halcyon.send(test_method).should == Halcyon.config[test_method.to_sym]
  end
  
  it "should predefine quick access to the 'db' configuration value" do
    Halcyon.db = 100
    Halcyon.db.should == Halcyon.config[:db]
  end
  
end
