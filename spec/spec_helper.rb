require File.join(File.dirname(__FILE__), '..', 'lib', 'halcyon')
require 'rack/mock'
require 'logger'

# Default Settings

Halcyon.config = Halcyon::Config.new(:environment => :test)

# Testing Application

# Default controller
class Application < Halcyon::Controller; end

# Weird edge-case controller
class Specs < Application
  
  before :before_index, :only => [:index]
  after :after_everything_but_index, :except => [:index]
  before :greeter do |controller|
    raise NotFound.new if controller.params[:cause_exception_in_filter_block]
  end
  
  def greeter
    $hello = params[:name]
    ok("Hello #{params[:name]}")
  end
  
  def index
    ok('Found')
  end
  
  # For testing headers in responses
  def goob
    ok "boog", 'Date' => Time.now.strftime("%a, %d %h %Y %H:%I:%S %Z"), 'Content-Language' => 'en'
  end
  
  # For testing various return types
  def gaff
    $return_value_for_gaff || ok
  end
  
  def foobar
    ok('fubr')
  end
  
  def unprocessable_entity_test
    error :unprocessable_entity
  end
  
  def cause_exception
    raise Exception.new("Oops!")
  end
  
  def call_nonexistent_method
    hash = Hash.new
    hash.please_dont_exist_and_please_throw_no_method_error
    ok
  end
  
  private
  
  def undispatchable_private_method
    "it's private, so it won't be found by the dispatcher"
  end
  
  def before_index
    raise Accepted.new if params[:cause_exception_in_filter]
  end
  
  def after_everything_but_index
    raise Created.new if params[:cause_exception_in_filter]
  end
  
end

# Resources controller
class Resources < Application

  def index
    ok('List of resources')
  end

  def show
    ok("One resource: #{params[:id]}")
  end
end

# Nested controller
module Nested
  class Tests < Application
    
    def index
      ok
    end
    
  end
end

# Models

class Model
  attr_accessor :id
end

# Environment

Halcyon.configurable_attr(:environment)

# Testing routes

Halcyon::Application.route do
  resources :resources
  
  match('/nested/tests').to(:controller => 'nested/tests', :action => 'index')
  match('/hello/:name').to(:controller => 'specs', :action => 'greeter')
  match('/:action').to(:controller => 'specs')
  match('/:controller/:action').to()
  match('/').to(:controller => 'specs', :action => 'index', :arbitrary => 'random')
  # default_routes
  
  {:action => 'missing'}
end

Halcyon::Application.startup do |config|
  $started = true
end
