class OrderedLineItemsDropPipingClassField < ActiveRecord::Migration
  	def self.up
  		remove_column :ordered_line_items, :piping_class
  	end

  	def self.down
		add_column :ordered_line_items, :piping_class, :string
  	end
end
