class AddUnitNoToUnitsTable < ActiveRecord::Migration
  def self.up
    add_column :units, :unit_no, :string    
  end

  def self.down
    remove_column :units, :unit_no
  end
end
