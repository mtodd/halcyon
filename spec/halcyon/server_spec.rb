describe "Halcyon::Server" do
  
  before do
    @app = Specr.new :port => 4000
  end
  
  it "should dispatch methods according to their respective routes" do
    Rack::MockRequest.new(@app).get("/hello/Matt")
    last_line = File.new(@app.instance_variable_get("@config")[:log_file]).readlines.last
    last_line.should =~ /INFO \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] \(\d+\) Specr#test :: \[200\] .* => greeter \(.+\)/
  end
  
  it "should provide various shorthand methods for simple responses but take custom response values" do
    response = {:status => 200, :body => 'OK'}
    @app.ok.should == response
    @app.success.should == response
    @app.standard_response.should == response
    
    @app.ok('').should == {:status => 200, :body => ''}
    @app.ok(['OK', 'Sure Thang', 'Correcto']).should == {:status => 200, :body => ['OK', 'Sure Thang', 'Correcto']}
  end
  
  it "should handle requests and respond with JSON" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/").body)
    body['status'].should == 200
    body['body'].should == "Found"
  end
  
  it "should handle requests with param values in the URL" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/hello/Matt").body)
    body['status'].should == 200
    body['body'].should == "Hello Matt"
  end
  
  it "should route unmatchable requests to the default route and return JSON with appropriate status" do
    body = JSON.parse(Rack::MockRequest.new(@app).get("/garbage/request/url").body)
    body['status'].should == 404
    body['body'].should == "Not Found"
  end
  
  it "should log activity" do
    prev_line = File.new(@app.instance_variable_get("@config")[:log_file]).readlines.last
    Rack::MockRequest.new(@app).get("/url/that/will/not/be/found/#{rand}")
    last_line = File.new(@app.instance_variable_get("@config")[:log_file]).readlines.last
    last_line.should =~ /INFO \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] \(\d+\) Specr#test :: \[404\] .* => not_found \(.+\)/
    prev_line.should_not == last_line
  end
  
  it "should create a PID file while running with the correct process ID" do
    pid_file = @app.instance_variable_get("@config")[:pid_file]
    File.exist?(pid_file).should be_true
    File.open(pid_file){|file|file.read.should == "#{$$}\n"}
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
  
  it "should deny all unacceptable requests" do
    conf = @app.instance_variable_get("@config")
    conf[:acceptable_requests] = Halcyon::Server::ACCEPTABLE_REQUESTS
    
    Rack::MockRequest.new(@app).get("/#{rand}")
    @app.acceptable_request! rescue Halcyon::Exceptions::Base
  end
  
  it "should record the correct environment details" do
    @app.instance_eval { @config[:root].should == Dir.pwd }
  end
  
end
