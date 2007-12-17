%w(rubygems halcyon/client halcyon/client/base).each{|dep|require dep}
class Simple < Halcyon::Client::Base
  route do |r|
    r.match('/user/show/:id').to(:module => 'user', :action => 'show')
    r.match('/show/:id').to(:action => 'show')
    r.match('/hello/:name').to(:action => 'greet')
    r.match('/wink').to(:action => 'wink')
    r.match('/').to(:action => 'index')
    {:action => 'what_are_you_looking_for?'}
  end
  def greet(name)
    get("/hello/#{name}")[:body]
  end
  def hi(name)
    url_for('greet', :name => name)
  end
end
