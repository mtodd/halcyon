class Answers < Application
  
  def check
    question = post[:question]
    answer = post[:answer]
    
    ok Guesser.guess(question, answer)
  end
  
end
