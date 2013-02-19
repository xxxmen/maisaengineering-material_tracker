# == Schema Information
# Schema version: 20090730175917
#
# Table name: companies
#
#  id           :integer(4)    not null, primary key
#  name         :string(255)   
#  address      :text          
#  city         :string(255)   
#  state        :string(255)   
#  zip          :string(255)   
#  telephone    :string(255)   
#  fax          :string(255)   
#  notes        :text          
#  lock_version :integer(4)    default(0)
#  updated_at   :datetime      
#

class Company < ActiveRecord::Base
  # Using ThinkingSphinx now... (Adam - 2009-06-18)
  # acts_as_ferret :fields => [:name]
  acts_as_log_edits

  extend Listable::ModelHelper

  has_many :employees, :foreign_key => "company_id"

  # Thinking Sphinx Config
  define_index do

    indexes :name
    set_property :delta => true
  end

  validates_uniqueness_of :name
  validates_presence_of :name

  PERPAGE = 100

  def self.list_companies(list_options = {})
    self.find(:all, :order => "name").map do |c|
      [c.name, (list_options[:name] ? c.name : c.id)]
    end.unshift(["", nil])
  end

  # Method for autocompletes that will list out all employee names that are similar to the 'query' parameter
  # If use_id is set to true, the results will be returned like this ("Hugh Bien (id)")
  def self.list_companies_for_autocomplete(query, use_id=false)
    self.find(:all, :conditions => ["name LIKE ?", '%' + query + '%'],  :order => "name ASC", :limit => 20).map do |c|
      c.name
    end
  end


  # ===============
  # = CSV support =
  # ===============

  comma do
    Company.column_names.each do |column_name|
      case column_name
        when 'delta'
          #skip
        else
          send(column_name,column_name.underscore)
      end
    end
  end



end
