describe "Halcyon::Server Errors" do
  
  before do
    @app = Specr.new :port => 4000
  end
  
  it "should provide shorthand methods for errors which should throw an appropriate exception" do
    begin
      @app.not_found
    rescue Halcyon::Exceptions::Base => e
      e.status.should == 404
      e.error.should == 'Not Found'
    end
    
    begin
      @app.not_found('Missing')
    rescue Halcyon::Exceptions::Base => e
      e.status.should == 404
      e.error.should == 'Missing'
    end
  end
  
  it "supports numerous standard HTTP request error exceptions with lookup by status code" do
    begin
      Halcyon::Server::Base::Exceptions::NotFound.new
    rescue Halcyon::Exceptions::Base => e
      e.status.should == 404
      e.error.should == 'Not Found'
    end
    
    Halcyon::Exceptions::HTTP_ERROR_CODES.each do |code, error|
      begin
        Halcyon::Server::Base::Exceptions.const_get(error.gsub(/( |\-)/,'')).new
      rescue Halcyon::Exceptions::Base => e
        e.status.should == code
        e.error.should == error
      end
      begin
        Halcyon::Server::Base::Exceptions.lookup(code).new
      rescue Halcyon::Exceptions::Base => e
        e.status.should == code
        e.error.should == error
      end
    end
  end
  
  it "should have a short inheritence chain to make catching generically simple" do
    begin
      Halcyon::Server::Base::Exceptions::NotFound.new
    rescue Halcon::Exceptions::Base => e
      e.class.to_s.should == 'NotFound'
    end
  end
  
end
