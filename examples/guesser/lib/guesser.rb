module Guesser
  
  VERSION = [0,1,0]
  
  class << self
    
    def version
      VERSION.join('.')
    end
    
    def guess(question, answer)
      response = false
      Questions.each do |problem|
        next unless problem[:question] == question
        response = (problem[:answer] == answer)
      end
      response
    end
    
  end
end
