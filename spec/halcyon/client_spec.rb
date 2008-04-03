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

at_exit do
  pids = (`ps aux | grep support/generators/halcyon/templates | cut -f 5 -d " "`).split("\n")
  pids.each {|pid| Process.kill(9, pid.to_i) rescue nil }
end

describe "Halcyon::Client" do
  
  before do
    @client = Halcyon::Client.new('http://localhost:89981')
  end
  
  it "should perform requests and return the response values" do
    response = @client.get('/time')['body']
    response.length.should > 25
    response.include?(Time.now.year.to_s).should.be.true?
  end
  
end
