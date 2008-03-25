class Application < Halcyon::Controller
  
  def index
    ok('Nothing here')
  end
  
  def time
    ok(Time.now.to_s)
  end
  
end
