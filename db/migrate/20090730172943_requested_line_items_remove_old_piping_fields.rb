class RequestedLineItemsRemoveOldPipingFields < ActiveRecord::Migration
  	def self.up
  		remove_column :requested_line_items, :size
  		remove_column :requested_line_items, :klass
  		remove_column :requested_line_items, :component
  	end

  	def self.down
  		add_column :requested_line_items, :size, :string
  		add_column :requested_line_items, :klass, :string
  		add_column :requested_line_items, :component, :string
  	end
end
