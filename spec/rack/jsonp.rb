app = lambda do |env|
  [200, {'Content-Type' => 'text/plain'}, {'bar' => 'foo'}.to_json]
end

jsonp_app = Rack::Builder.new do
  use Rack::JSONP
  run app
end

describe "Rack::JSONP" do
  
  before do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    Halcyon.config.use do |c|
      c[:logger] = @logger
    end
    @app = Halcyon::Runner.new
  end
  
  it "should wrap the response body in the Javascript callback when provided" do
    body = jsonp_app.call(Rack::MockRequest.env_for("/", :input => "foo=bar&callback=foo")).last
    body.should == 'foo({"bar":"foo"})'
  end
  
  it "should not change anything if no :callback param is provided" do
    body = app.call(Rack::MockRequest.env_for("/", :input => "foo=bar")).last
    body.should == {'bar' => 'foo'}.to_json
  end
  
end
