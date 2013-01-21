class ValvesValveComponentsChangeComponentText < ActiveRecord::Migration
	def self.up
  		change_column :valves_valve_components, :component_text, :text
  	end

  	def self.down
  	end
end
