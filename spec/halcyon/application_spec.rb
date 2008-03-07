describe "Halcyon::Application" do
  
  before do
    @log = ""
    @app = Specr.new :port => 4000, :logger => Logger.new(StringIO.new(@log))
  end
  
  it "should run startup hook if defined" do
    @app.instance_variable_get("@started").should.be.true?
  end
  
  it "should dispatch methods according to their respective routes" do
    Rack::MockRequest.new(@app).get("/hello/Matt")
    @log.should =~ /INFO \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] \(\d+\) Specr :: \[200\] \/hello\/Matt \(.+\)/
  end
  
  it "should provide various shorthand methods for simple responses but take custom response values" do
    response = {:status => 200, :body => 'OK'}
    @app.ok.should == response
    @app.success.should == response
    
    @app.ok('').should == {:status => 200, :body => ''}
    @app.ok(['OK', 'Sure Thang', 'Correcto']).should == {:status => 200, :body => ['OK', 'Sure Thang', 'Correcto']}
  end
  
  it "should handle requests and respond with JSON" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/").body)
    body['status'].should == 200
    body['body'].should == "Found"
  end
  
  it "should handle requests with param values in the URL" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/hello/Matt?test=value").body)
    body['status'].should == 200
    body['body'].should == "Hello Matt"
    @app.params[:test].should == 'value'
  end
  
  it "should route unmatchable requests to the default route and return JSON with appropriate status" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/garbage/request/url").body)
    body['status'].should == 404
    body['body'].should == "Not Found"
  end
  
  it "should log activity" do
    @app.instance_variable_get("@logger").is_a?(Logger).should.be.true?
  end
  
  it "should parse URI query params correctly" do
    Rack::MockRequest.new(@app).get("/?query=value&lang=en-US")
    @app.query_params.should == {'query' => 'value', 'lang' => 'en-US'}
  end
  
  it "should parse the URI correctly" do
    Rack::MockRequest.new(@app).get("http://localhost:4000/slaughterhouse/5")
    @app.uri.should == '/slaughterhouse/5'
    
    Rack::MockRequest.new(@app).get("/slaughterhouse/5")
    @app.uri.should == '/slaughterhouse/5'
    
    Rack::MockRequest.new(@app).get("")
    @app.uri.should == '/'
  end
  
  it "should provide a quick way to find out what method the request was performed using" do
    Rack::MockRequest.new(@app).get("/#{rand}")
    @app.method.should == :get
    
    Rack::MockRequest.new(@app).post("/#{rand}")
    @app.method.should == :post
    
    Rack::MockRequest.new(@app).put("/#{rand}")
    @app.method.should == :put
    
    Rack::MockRequest.new(@app).delete("/#{rand}")
    @app.method.should == :delete
  end
  
  it "should provide convenient access to GET and POST data" do
    Rack::MockRequest.new(@app).get("/#{rand}?foo=bar")
    @app.get[:foo].should == 'bar'
    
    Rack::MockRequest.new(@app).post("/#{rand}", :input => {:foo => 'bar'}.to_params)
    @app.post[:foo].should == 'bar'
  end
  
  it "should allow all requests by default" do
    @app.instance_variable_get("@options")[:allow_from].should == :all
  end
  
  it "should record the correct environment details" do
    @app.instance_eval { @options[:root].should == Dir.pwd }
  end
  
  it "should handle exceptions gracefully" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/failure").body)
    body['status'].should == 500
    body['body'].should == "Internal Server Error"
  end
  
end
