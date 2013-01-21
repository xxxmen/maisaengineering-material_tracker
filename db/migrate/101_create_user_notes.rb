class CreateUserNotes < ActiveRecord::Migration
	def self.up
		create_table :user_notes do |t|
			t.string :table_type
			t.string :table_id
			t.string :table_field_name
			t.string :table_field_data
			t.string :note
			t.integer :created_by
			t.integer :acknowledged_by
			t.integer :declined_by
			t.integer :implemented_by
			t.timestamps 
    	end
    	add_index :user_notes, [:table_type, :table_id]
    	
    	#add other indexes as needed
    	
    	add_index :valves_valve_components, [:valve_id, :valve_component_id]
    	add_index :manufacturers_valves, [:manufacturer_id, :valve_id]
	end
	
	def self.down
		
		drop_table 'user_notes'
		remove_index :valves_valve_components, [:valve_id, :valve_component_id]
    	remove_index :manufacturers_valves, [:manufacturer_id, :valve_id]
	end
	
end
	