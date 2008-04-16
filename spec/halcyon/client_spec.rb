#--
# Start App for Tests
# and wait for it to be responsive
#++

fork do
  dir = Halcyon.root/'support'/'generators'/'halcyon'/'templates'
  command = "thin start -r runner.ru -p 89981 -c #{dir} > /dev/null 2>&1"
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
    @client.raise_exceptions! true
    should.raise(Halcyon::Exceptions::NotFound) { @client.get('/nonexistent/route') }
    @client.get('/time')[:status].should == 200
  end
  
end
