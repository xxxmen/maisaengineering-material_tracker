# Fixes an error where Rails 2.3.2 balks when a column is named :class
# We don't seem to be using that column anywhere anyway.
class OrderedLineItemsRenameClassColumn < ActiveRecord::Migration
  	def self.up
  		rename_column :ordered_line_items, :class, :piping_class
  	end

  	def self.down
  		rename_column :ordered_line_items, :piping_class, :class
  	end
end
