class Questions < Application
  
  def random
    problem = Guesser::Questions[rand(Guesser::Questions.length)]
    response = {
      :question => problem[:question],
      :options => problem[:options]
    }
    ok response
  end
  
  def show
    case params[:id]
    when "random"
      self.random
    else
      #
    end
  end
  
end
