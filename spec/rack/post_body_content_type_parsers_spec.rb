app = lambda do |env|
  request = Rack::Request.new(env)
  [200, {'Content-Type' => 'text/plain'}, request.POST]
end

def env_for_post_with_headers(path, headers, body)
  Rack::MockRequest.env_for(path, {:method => "POST", :input => body}.merge(headers))
end

describe "Rack::PostBodyContentTypeParsers" do
  
  before do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    Halcyon.config.use do |c|
      c[:logger] = @logger
    end
    @app = Halcyon::Runner.new
  end
  
  it "should handle requests with POST body Content-Type of application/json" do
    parser = Rack::PostBodyContentTypeParsers.new(app)
    env = env_for_post_with_headers('/', {'Content_Type'.upcase => 'application/json'}, {:body => "asdf", :status => "12"}.to_json)
    
    response_body = parser.call(env).last
    
    response_body['body'].should == "asdf"
    response_body['status'].should == "12"
  end
  
  it "should change nothing when the POST body content type isn't application/json" do
    response_body = app.call(Rack::MockRequest.env_for("/", :input => "body=asdf&status=12")).last
    response_body['body'].should == "asdf"
    response_body['status'].should == "12"
  end
  
end
