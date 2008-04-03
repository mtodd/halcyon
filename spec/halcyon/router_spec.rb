describe "Halcyon::Application::Router" do
  
  before do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    @config = $config.dup
    @config[:logger] = @logger
    Halcyon.config = @config
    @app = Halcyon::Runner.new
  end
  
  it "should prepare routes correctly when written correctly" do
    # routes have been defined for Specr
    Halcyon::Application::Router.routes.should.not == []
    Halcyon::Application::Router.routes.length.should > 0
  end
  
  it "should match URIs to the correct route" do
    request = Rack::Request.new(Rack::MockRequest.env_for('/'))
    Halcyon::Application::Router.route(request)[:action].should == 'index'
  end
  
  it "should use the default route if no matching route is found" do
    # missing instead of not_found because we gave a different default route 
    request = Rack::Request.new(Rack::MockRequest.env_for("/erroneous/path/#{rand}/#{rand}"))
    Halcyon::Application::Router.route(request)[:action].should == 'missing'
    
    request = Rack::Request.new(Rack::MockRequest.env_for("/random/#{rand}/#{rand}"))
    Halcyon::Application::Router.route(request)[:action].should == 'missing'
  end
  
  it "should map params in routes to parameters" do
    request = Rack::Request.new(Rack::MockRequest.env_for('/hello/Matt'))
    response = Halcyon::Application::Router.route(request)
    response[:action].should == 'greeter'
    response[:name].should == 'Matt'
  end
  
  it "should supply arbitrary routing param values included as a param even if not in the URI" do
    request = Rack::Request.new(Rack::MockRequest.env_for('/'))
    request.env['rack.input'] << "arbitrary=random"
    Halcyon::Application::Router.route(request)[:arbitrary].should == 'random'
  end
  
end
