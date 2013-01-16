class AddDeltaFields < ActiveRecord::Migration
  def self.up
  	[:carts, :companies, :employees, :general_references, 
	  	:inventory_items, :ordered_line_items, :purchase_orders, :units, :vendors].each do |table|
  		add_column table, :delta, :boolean, :default => true, :null => false
  	end
  end

  def self.down
  	[:carts, :companies, :employees, :general_references, 
	  	:inventory_items, :ordered_line_items, :purchase_orders, :units, :vendors].each do |table|
  		remove_column table, :delta
  	end
  end
end
