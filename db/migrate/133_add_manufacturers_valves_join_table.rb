class AddManufacturersValvesJoinTable < ActiveRecord::Migration
	def self.up
		create_table :manufacturers_valves, :force => true do |t|
			t.integer	:manufacturer_id
			t.integer	:valve_id
		end
  	end

  	def self.down
  		drop_table :manufacturers_valves
  	end
end
