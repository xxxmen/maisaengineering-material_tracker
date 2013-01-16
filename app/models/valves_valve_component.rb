# == Schema Information
# Schema version: 20090730175917
#
# Table name: valves_valve_components
#
#  id                 :integer(4)    not null, primary key
#  component_text     :text          
#  valve_component_id :integer(10)   
#  valve_id           :integer(10)   
#

class ValvesValveComponent < ActiveRecord::Base
    belongs_to :valve_component
    belongs_to :valve
    has_many :user_notes, :as => :table
    SEXT_INCLUDE = [:user_notes, :valve, :valve_component]
    def sext_data(options = {})
	  json = super()
	  json[:component_name] = self.valve_component.component_name
	  return json
    end
end
	
