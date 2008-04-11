require 'ostruct'

describe "Halcyon::Controller" do
  
  before do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    @config = $config.dup
    @config[:logger] = @logger
    @config[:app] = 'Specs'
    Halcyon.config = @config
    @app = Halcyon::Runner.new
  end
  
  it "should provide various shorthand methods for simple responses but take custom response values" do
    controller = Specs.new(Rack::MockRequest.env_for('/'))
    
    response = {:status => 200, :body => 'OK'}
    controller.ok.should == response
    controller.success.should == response
    
    controller.ok('').should == {:status => 200, :body => ''}
    controller.ok(['OK', 'Sure Thang', 'Correcto']).should == {:status => 200, :body => ['OK', 'Sure Thang', 'Correcto']}
  end
  
  it "should provide a quick way to find out what method the request was performed using" do
    %w(GET POST PUT DELETE).each do |m|
      controller = Specs.new(Rack::MockRequest.env_for('/', :method => m))
      controller.method.should == m.downcase.to_sym
    end
  end
  
  it "should provide convenient access to GET and POST data" do
    controller = Specs.new(Rack::MockRequest.env_for("/#{rand}?foo=bar"))
    controller.get[:foo].should == 'bar'
    
    controller = Specs.new(Rack::MockRequest.env_for("/#{rand}", :method => 'POST', :input => {:foo => 'bar'}.to_params))
    controller.post[:foo].should == 'bar'
  end
  
  it "should parse URI query params correctly" do
    controller = Specs.new(Rack::MockRequest.env_for("/?query=value&lang=en-US"))
    controller.get[:query].should == 'value'
    controller.get[:lang].should == 'en-US'
  end
  
  it "should parse the URI correctly" do
    controller = Specs.new(Rack::MockRequest.env_for("http://localhost:4000/slaughterhouse/5"))
    controller.uri.should == '/slaughterhouse/5'
    
    controller = Specs.new(Rack::MockRequest.env_for("/slaughterhouse/5"))
    controller.uri.should == '/slaughterhouse/5'
    
    controller = Specs.new(Rack::MockRequest.env_for(""))
    controller.uri.should == '/'
  end

  it 'should provide url accessor for resource index route' do
    controller = Resources.new(Rack::MockRequest.env_for("/resources"))
    controller.uri.should == controller.url(:resources)
  end

  it 'should provide url accessor for resource show route' do
    resource = Model.new
    resource.id = 1
    controller = Resources.new(Rack::MockRequest.env_for("/resources/1"))
    controller.uri.should == controller.url(:resource, resource)
  end
  
end
