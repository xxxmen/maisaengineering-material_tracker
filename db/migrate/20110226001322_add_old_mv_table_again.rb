class AddOldMvTableAgain < ActiveRecord::Migration
  def self.up
  	create_table "old_manufacturers_valves", :force => true do |t|
		t.integer "manufacturer_id"
		t.integer "valve_id"
		t.text    "figure_no"
	end
  end

  def self.down
  end
end
