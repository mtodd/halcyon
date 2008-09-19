#--
# Start App for Tests
# and wait for it to be responsive
#++

fork do
  dir = Halcyon.root/'support'/'generators'/'halcyon'/'templates'
  command = "thin start -R runner.ru -p 89981 -c #{dir} > /dev/null 2>&1"
  STDOUT.close
  STDERR.close
  exec command
end
client = Halcyon::Client.new('http://localhost:89981')
begin
  sleep 1.5
  client.get('/time')
rescue Errno::ECONNREFUSED => e
  retry
end

#--
# Cleanup
#++

at_exit do
  pids = (`ps auxww | grep support/generators/halcyon/templates`).split("\n").collect{|pid|pid.match(/(\w+)\s+(\w+).+/)[2]}
  pids.each {|pid| Process.kill(9, pid.to_i) rescue nil }
end

#--
# Tests
#++

module Halcyon
  class Client
    private
    def prepare_server(serv)
      class << serv
        alias :request_without_header_inspection :request
        def request(req, body = nil, &block)
          $accept = req["Accept"]
          request_without_header_inspection(req, body, &block)
        end
      end
    end
  end
end

describe "Halcyon::Client" do
  
  before do
    @client = Halcyon::Client.new('http://localhost:89981')
  end
  
  it "should perform requests and return the response values" do
    response = @client.get('/time')[:body]
    response.length.should > 25
    response.include?(Time.now.year.to_s).should.be.true?
  end
  
  it "should be able to perform get, post, put, and delete requests" do
    @client.get('/time')[:body].length.should > 25
    @client.post('/time')[:body].length.should > 20
    @client.put('/time')[:body].should == "Not Implemented"
    @client.delete('/time')[:status].should == 501
  end
  
  it "should throw exceptions unless an OK response is sent if toggled to" do
    # default behavior is to not raise exceptions
    @client.get('/nonexistent/route')[:status].should == 404
    
    # tell it to raise exceptions
    @client.raise_exceptions!
    should.raise(Halcyon::Exceptions::NotFound) { @client.get('/nonexistent/route') }
    @client.get('/time')[:status].should == 200
  end
  
  it "should handle ampersands (and others) in POST data correctly" do
    response = @client.post('/returner', :key => "value1&value2=0")
    response[:status].should == 200
    response[:body].should == {'controller' => 'application', 'action' => 'returner', 'key' => "value1&value2=0"}
    
    response = @client.post('/returner', :key => "%todd")
    response[:status].should == 200
    response[:body].should == {'controller' => 'application', 'action' => 'returner', 'key' => "%todd"}
  end
  
  it "should not handle percent signs in the URL that are not escaped" do
    should.raise(EOFError){ @client.post('/returner?key=%todd') }
  end
  
  it "should handle pre-escaped percent signs in the URLs" do
    response = @client.post('/returner?key=%25todd')
    response[:status].should == 200
    response[:body].should == {'controller' => 'application', 'action' => 'returner', 'key' => "%todd"}
  end
  
  it "should render the POST body with the correct content type, allowing application/json is set" do
    body = {:key => "value"}
    
    # default behavior is to set the POST body to application/x-www-form-urlencoded
    @client.send(:format_body, body) == "key=value"
    @client.post('/returner', body)[:body][:key].should == "value"
    
    # tell it to send as application/json
    @client.encode_post_body_as_json!
    @client.send(:format_body, body).should == body.to_json
    @client.post('/returner', body)[:body][:key].should == nil
    # The server will not return the values from the POST body because it is
    # not set to parse application/json values. Like your own apps, you must
    # set it manually to accept this type of body encoding.
    
    # set it back to ensure that the change is reversed
    @client.encode_post_body_as_json! false
    @client.send(:format_body, body) == "key=value"
    @client.post('/returner', body)[:body][:key].should == "value"
  end
  
  it "should set the Accept header to the appropriate type" do
    @client.get('/returner')[:status].should == 200
    $accept.should == Halcyon::Client::ACCEPT
  end
  
end
