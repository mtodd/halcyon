describe "Halcyon::Runner" do
  
  before do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    @config = $config.dup
    @config[:logger] = @logger
    Halcyon.config = @config
    @app = Halcyon::Runner.new
  end
  
  it "should raise an exception if a non-existent config file is loaded" do
    should.raise(LoadError) { Halcyon::Runner.load_config(Halcyon.root/'config'/'config.yml') }
  end
  
  it "should set up logging according to configuration" do
    time = Time.now.to_s
    @app.logger.debug "Test message for #{time}"
    @log.should =~ /Test message for #{time}/
  end
  
  it "should recognize what application it is running as" do
    # Without setting explicitly in config
    Halcyon.app.should == Halcyon.root.split('/').last.camel_case
    
    # With setting explicitly in config
    Halcyon.config[:app] = 'Specr'
    Halcyon::Runner.new
    Halcyon.app.should == 'Specr'
    
    # Setting directly
    Halcyon.app = 'Specr2'
    Halcyon.app.should == 'Specr2'
  end
  
  it "should proxy calls to Halcyon::Application" do
    status, headers, body = @app.call(Rack::MockRequest.env_for('/'))
    status.should == 200
    body.body[0].should == Specs.new(Rack::MockRequest.env_for('/')).send(:index).to_json
  end
  
end
