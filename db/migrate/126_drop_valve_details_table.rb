class DropValveDetailsTable < ActiveRecord::Migration
  def self.up
    drop_table :valve_details
  end

  def self.down
  end
end
