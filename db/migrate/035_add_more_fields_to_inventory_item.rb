class AddMoreFieldsToInventoryItem < ActiveRecord::Migration
  def self.up
    add_column :inventory_items, :shortcut_no, :string
  end

  def self.down
    remove_column :inventory_items, :shortcut_no
  end
end
