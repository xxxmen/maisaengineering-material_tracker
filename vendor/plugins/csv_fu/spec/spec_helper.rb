require 'rubygems'
require "fastercsv"
require File.dirname(__FILE__) + "/../lib/csv_fu"

RAILS_ROOT = File.dirname(__FILE__) + "/../sandbox"

class User
  extend CsvFu::ClassMethods
  include CsvFu::InstanceMethods
  
  @@all = []
  @@created = []
  
  attr_accessor :login, :name, :password
  
  def initialize(login = nil, name = nil, password = nil)
    @login, @name, @password = login, name, password
  end
  
  def self.create!(attrs)
    @@created << User.new(attrs["login"], attrs["name"], attrs["password"])
  end
  
  def save!
    @@created << self
  end
  
  # Stub out some stuff
  def self.find(*args)
    return @@all
  end
  
  def self.all=(users)
    @@all = users
  end
  
  def self.created
    @@created
  end
  
  def self.column_names
    [:login, :name, :password]
  end
  
  def self.table_name
    "users"
  end
end

module ActiveRecord
  class Base
    def self.lock_optimistically=(val)
    end
  end
end
