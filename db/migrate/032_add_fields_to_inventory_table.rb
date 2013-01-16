class AddFieldsToInventoryTable < ActiveRecord::Migration
  def self.up
    change_column :inventory_items, :consignment_count, :decimal, :precision => 15, :scale => 2
    change_column :inventory_items, :total_count, :decimal, :precision => 15, :scale => 2
    change_column :inventory_items, :on_hand, :decimal, :precision => 15, :scale => 2
    
    add_column :inventory_items, :building, :string
  end

  def self.down
    change_column :inventory_items, :consignment_count, :integer
    change_column :inventory_items, :total_count, :integer
    change_column :inventory_items, :on_hand, :integer
    
    remove_column :inventory_tables, :building, :string
  end
end
