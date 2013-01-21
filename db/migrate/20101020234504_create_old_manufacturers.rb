class CreateOldManufacturers < ActiveRecord::Migration
  def self.up
    #create a backup table in the 'old_manufacturers_valves' join
	create_table "old_manufacturers_valves", :force => true do |t|
		t.integer "manufacturer_id"
		t.integer "valve_id"
		t.text    "figure_no"
	end

 end

  def self.down
  	drop_table :old_manufacturers_valves
  end
end
