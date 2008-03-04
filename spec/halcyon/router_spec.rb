describe "Halcyon::Server::Router" do
  
  before do
    @log = ""
    @app = Specr.new :port => 4000, :logger => Logger.new(StringIO.new(@log))
  end
  
  it "should prepares routes correctly when written correctly" do
    # routes have been defined for Specr
    Halcyon::Application::Router.routes.should.not == []
    Halcyon::Application::Router.routes.length.should > 0
  end
  
  it "should match URIs to the correct route" do
    Halcyon::Application::Router.route(Rack::MockRequest.env_for('/'))[:action].should == 'index'
  end
  
  it "should use the default route if no matching route is found" do
    Halcyon::Application::Router.route(Rack::MockRequest.env_for("/erroneous/path/#{rand}/#{rand}"))[:action].should == 'not_found'
    Halcyon::Application::Router.route(Rack::MockRequest.env_for("/random/#{rand}/#{rand}"))[:action].should == 'not_found'
  end
  
  it "should map params in routes to parameters" do
     response = Halcyon::Application::Router.route(Rack::MockRequest.env_for('/hello/Matt'))
     response[:action].should == 'greeter'
     response[:name].should == 'Matt'
  end
  
  it "should supply arbitrary routing param values included as a param even if not in the URI" do
    Halcyon::Application::Router.route(Rack::MockRequest.env_for('/'))[:arbitrary].should == 'random'
  end
  
end
