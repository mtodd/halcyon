describe "Halcyon" do
  
  before do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    @config = $config.dup
    @config[:logger] = @logger
    @config[:app] = 'Specs'
    Halcyon.config = @config
    @app = Halcyon::Runner.new
  end
  
  it "should provide the path of the application root directory" do
    Halcyon.root.should == Dir.pwd
  end
  
  it "should provide quick access to the configuration hash" do
    Halcyon.config.is_a?(Hash).should.be.true?
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
    Halcyon.paths.is_a?(Hash).should.be.true?
    Halcyon.paths[:controller].should == Halcyon.root/"app"
    Halcyon.paths[:lib].should == Halcyon.root/"lib"
    Halcyon.paths[:config].should == Halcyon.root/"config"
    Halcyon.paths[:init].should == Halcyon.root/"config"/"{init,initialize}"
    Halcyon.paths[:log].should == Halcyon.root/"log"
  end
  
end
