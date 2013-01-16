class AddValveFieldsFromComponents < ActiveRecord::Migration
  	def self.up
  		add_column :valves, :valve_body, :text
  		add_column :valves, :valve_rating, :text
  		add_column :valves, :valve_type, :text
  	end

  	def self.down
  		remove_column :valves, :valve_body
  		remove_column :valves, :valve_rating
  		remove_column :valves, :valve_type
  	end
end
