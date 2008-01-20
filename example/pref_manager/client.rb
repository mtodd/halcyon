#!/usr/bin/env ruby -wKU

%w(rubygems halcyon/client).each{|dep|require dep}

$port = 4447 if $0 == __FILE__

class PrefManager < Halcyon::Client::Base
  def find(user)
    get("/u/#{user}/prefs")[:body]
  end
  def create(user, pref, value)
    put("/u/#{user}/p/#{pref}", {:value => value})[:body]
  end
  def read(user, pref)
    get("/u/#{user}/p/#{pref}")[:body]
  end
  def update(user, pref, value)
    post("/u/#{user}/p/#{pref}", {:value => value})[:body]
  end
  def delete(user, pref)
    delete("/u/#{user}/p/#{pref}")[:body]
  end
end

class Pref
  def initialize(user, pref)
    @@manager ||= PrefManager.new("http://localhost:#{$port}")
    @user = user
    @pref = pref
    @value = @@manager.read(@user, @pref)[:value]
  end
  def self.find(user, pref)
    self.new(user, pref)
  end
  def set(value)
    @value = value
  end
  def get
    @value
  end
  def method_missing(name, *params)
    case name.to_s
    when "#{@pref}"
      @value
    when "#{@pref}="
      @value = params[0]
    else
      super
    end
  end
  def save
    @@manager.update(@user, @pref, @value)
  end
  def destroy
    @@manager.delete(@user, @pref)
  end
end

if $0 == __FILE__
  users = ['mtodd','chris2','aurora','kate','jpatterson']
  delivery_types = [:digest,:full,:none]
  users.each do |user|
    pref = Pref.find(user,'email')
    pref.set delivery_types[rand(delivery_types.length)]
    pref.save
  end
end
