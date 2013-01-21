# == Schema Information
# Schema version: 20090730175917
#
# Table name: unit_for_measures
#
#  id          :integer(4)    not null, primary key
#  name        :string(255)   
#  description :string(255)   
#

class UnitForMeasure < ActiveRecord::Base
    validates_presence_of :name
    validates_presence_of :description
    def self.list_all
        UnitForMeasure.find(:all, :order => "name").map { |e| [e.name] }
    end
    
    def sext_data(options = {})
        json = super()
        json[:combined] = self.name + " - " + self.description
        return json
    end 
end
