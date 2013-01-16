class RemoveDirtyFlags < ActiveRecord::Migration
  def self.up
    remove_column :purchase_orders, :dirty
    remove_column :vendors, :dirty
    remove_column :employees, :dirty
    remove_column :companies, :dirty
    remove_column :units, :dirty
    remove_column :ordered_line_items, :dirty
    remove_column :virtual_badges, :dirty
  end

  def self.down
    add_column :purchase_orders, :dirty, :integer
    add_column :vendors, :dirty, :integer
    add_column :employees, :dirty, :integer
    add_column :companies, :dirty, :integer
    add_column :units, :dirty, :integer
    add_column :ordered_line_items, :dirty, :integer
    add_column :virtual_badges, :dirty, :integer
  end
end
