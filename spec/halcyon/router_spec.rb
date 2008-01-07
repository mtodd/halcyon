context "Halcyon::Server::Router" do
  
  before(:each) do
    @app = Specr.new :port => 4000
  end
  
  specify "should prepares routes correctly when written correctly" do
    # routes have been defined for Specr
    Halcyon::Server::Router.routes.should_not == []
    Halcyon::Server::Router.routes.length.should > 0
  end
  
  specify "should match URIs to the correct route" do
    Halcyon::Server::Router.route(Rack::MockRequest.env_for('/'))[:action].should == 'index'
  end
  
  specify "should use the default route if no matching route is found" do
    Halcyon::Server::Router.route(Rack::MockRequest.env_for('/erroneous/path'))[:action].should == 'not_found'
    Halcyon::Server::Router.route(Rack::MockRequest.env_for("/random/#{rand}"))[:action].should == 'not_found'
  end
  
  specify "should map params in routes to parameters" do
     response = Halcyon::Server::Router.route(Rack::MockRequest.env_for('/hello/Matt'))
     response[:action].should == 'greeter'
     response[:name].should == 'Matt'
  end
  
  specify "should supply arbitrary routing param values included as a param even if not in the URI" do
    Halcyon::Server::Router.route(Rack::MockRequest.env_for('/'))[:arbitrary].should == 'random'
  end
  
end
