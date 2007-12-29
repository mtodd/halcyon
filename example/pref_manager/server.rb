#!/usr/bin/env ruby -wKU

%w(halcyon/server pstore).each{|dep|require dep}

# Handles the persistence of preferences.
class Pref
  
  attr_accessor :prefs
  
  # Connects to the datastore and loads up the preferences
  def initialize(user)
    @user = user
    @@prefs ||= PStore.new("prefs.db.pstore")
    @@prefs.transaction(true) do
      @prefs = @@prefs.fetch(@user, {})
    end
  end
  
  # Convenience method to say "user.name"
  def name
    @user
  end
  
  # Saves the current prefs into the datastore
  def save
    @@prefs.transaction do
      @@prefs[@user] = @prefs
    end
  end
  
  # Accesses current preference value
  def [] key
    @prefs[key]
  end
  
  # Sets current preference value
  def []= key, value
    @prefs[key] = value
  end
  
end

# The Halcyon server, exposing the +/u/:user/p/:pref+ address as a HUB for
# various user's preference actions, essentially the CRUD functionality.
class Server < Halcyon::Server::Base
  route do |r|
    r.match('/u/:user/p/:pref').to(:action => 'pref')
    r.match('/u/:user/prefs').to(:action => 'prefs')
  end
  
  # Retreives all of the preferences for a given user
  def prefs(params)
    ok Pref.new(params[:user]).prefs
  end
  
  # Handles preference CRUD
  def pref(params)
    # get data
    user = Pref.new(params[:user])
    pref = params[:pref]
    value = user[pref]
    
    # dispatch
    case method
    when :get
      puts "read #{pref} for #{user.name}" if $debug
      ok :user => user.name, :pref => pref, :value => value
    when :post
      puts "update #{pref} for #{user.name}" if $debug
      value = user[pref] = @req.POST['value']
      user.save
      ok :user => user.name, :pref => pref, :value => value
    when :put
      puts "create #{pref} for #{user.name}" if $debug
      value = user[pref] = @req.POST['value']
      user.save
      ok :user => user.name, :pref => pref, :value => value
    when :delete
      puts "delete #{pref} for #{user.name}" if $debug
      value = user[pref] = nil
      user.save
      ok :user => user.name, :pref => pref, :value => value
    else
      puts "Weird request made with an unknown request method: #{method}" if $debug
      raise Exceptions.lookup(406) # Not Acceptable
    end
  end
  
end
