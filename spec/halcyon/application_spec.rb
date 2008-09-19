describe "Halcyon::Application" do
  
  before do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    Halcyon.config.use do |c|
      c[:logger] = @logger
    end
    @app = Halcyon::Runner.new
  end
  
  it "should run startup hook if defined" do
    # $started is set by the startup hook
    $started.should.be.true?
  end
  
  it "should dispatch methods according to their respective routes" do
    Rack::MockRequest.new(@app).get("/hello/Matt")
    $hello.should == "Matt"
  end
  
  it "should handle requests and respond with JSON" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/").body)
    body['status'].should == 200
    body['body'].should == "Found"
  end
  
  it "should not dispatch private methods" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/specs/undispatchable_private_method").body)
    body['status'].should == 404
    body['body'].should == "Not Found"
  end
  
  it "should route unmatchable requests to the default route and return JSON with appropriate status" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/garbage/request/url").body)
    body['status'].should == 404
    body['body'].should == "Not Found"
  end
  
  it "should log activity" do
    Halcyon.logger.is_a?(Logger).should.be.true?
    # Rack::MockRequest.new(@app).get("/lolcats/r/cute")
    # @log.should =~ / INFO \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] \(\d+\) Specs :: \[404\] \/lolcats\/r\/cute \(.+\)\n/
    # Halcyon.logger.debug "Testing"
    # @log.should =~ /Testing/
  end
  
  it "should allow all requests by default" do
    Halcyon.config[:allow_from].to_sym.should == :all
  end
  
  it "should handle exceptions gracefully" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/specs/cause_exception").body)
    body['status'].should == 500
    body['body'].should == "Internal Server Error"
  end
  
  it "should not confuse a NoMethodFound error in an action as a missing route" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/specs/call_nonexistent_method").body)
    body['status'].should.not == 404
    body['body'].should == "Internal Server Error"
  end
  
  it "should dispatch to controllers inside of modules" do
    response = Rack::MockRequest.new(@app).get("/nested/tests")
    response.status.should == 200
  end
  
end
