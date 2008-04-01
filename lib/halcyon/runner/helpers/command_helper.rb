module Halcyon
  class Runner
    class Helpers
      module CommandHelper
        
        def usage
          msg = <<-"end;"
            
            These methods will provide you with most of the
            functionality you will need to test your app.
            
            #app      The loaded application
            #log      The contents of the log (Ex: puts log)
            #tail     The tail end of the log (Ex: tail)
            #clear    Clears the log          (Ex: clear)
            #get      Sends a GET request to the app
                      Ex: get '/controller/action'
            #post     Sends a POST request to #app
                      Ex: post '/controller/action', :key => value
            #put      See #post
            #delete   See #get
            #response Response of the last request
            
          end;
          puts msg.gsub(/^[ ]{12}/, '')
        end
        
        def app
          $app
        end
        
        def log
          $log
        end
        
        def tail
          puts $log.split("\n").reverse[0..5].reverse.join("\n")
        end
        
        def clear
          $log = ''
        end
        
        def get(path)
          $response = Rack::MockRequest.new($app).get(path)
          JSON.parse($response.body)
        end
        
        def post(path, params = {})
          $response = Rack::MockRequest.new($app).post(path, :input => params.to_params)
          JSON.parse($response.body)
        end
        
        def put(path, params = {})
          $response = Rack::MockRequest.new($app).put(path, :input => params.to_params)
          JSON.parse($response.body)
        end
        
        def delete(path)
          $response = Rack::MockRequest.new($app).delete(path)
          JSON.parse($response.body)
        end
        
        def response
          $response
        end
        
      end
    end
  end
end
