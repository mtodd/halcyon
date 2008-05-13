# The WeeDB database.
module WeeDB
  
  VERSION = [0,0,0]
  
  class << self
    
    def version
      VERSION.join('.')
    end
    
    def generate_unique_url_key
      loop do
        key = Digest::MD5.hexdigest(Time.now.usec.to_s)[0..3]
        return key if Record[:url => key].nil?
      end
    end
    
  end
  
end
