class ValveComponentsAddOrderNumbering < ActiveRecord::Migration
  	def self.up
  		add_column :valve_components, :order_numbering, :integer
  	end

  	def self.down
  		remove_column :valve_components, :order_numbering
  	end
end
