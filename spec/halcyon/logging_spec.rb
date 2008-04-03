describe "Halcyon::Logging" do
  
  it "should set the default logger when none specified" do
    Halcyon.send(:remove_const, :Logger)
    Halcyon::Logging.set
    Halcyon::Logger.ancestors.include?(::Logger).should.be.true?
  end
  
  it "should set the logger type specified" do
    Halcyon.send(:remove_const, :Logger)
    Halcyon::Logging.set('Logger')
    Halcyon::Logger.ancestors.include?(::Logger).should.be.true?
    
    Halcyon.send(:remove_const, :Logger)
    Halcyon::Logging.set('Analogger')
    Halcyon::Logger.ancestors.include?(::Swiftcore::Analogger::Client).should.be.true?
    
    Halcyon.send(:remove_const, :Logger)
    Halcyon::Logging.set('Log4r')
    Halcyon::Logger.ancestors.include?(::Log4r::Logger).should.be.true?
    
    # Halcyon.send(:remove_const, :Logger)
    # Halcyon::Logging.set('Logging')
    # Halcyon::Logger.ancestors.include?(::Logging::Logger).should.be.true?
  end
  
end
