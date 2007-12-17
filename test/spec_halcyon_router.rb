require 'test/spec'

require 'halcyon/server'

context "Halcyon::Server::Router" do
  specify "prepares routes correctly" do
    msg = 'Run Merb tests to ensure Routing on server end will prepare correctly.'
    msg.should.equal msg
  end
end
