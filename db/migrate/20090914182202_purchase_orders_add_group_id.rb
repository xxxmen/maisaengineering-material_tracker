class PurchaseOrdersAddGroupId < ActiveRecord::Migration
	def self.up
		add_column :purchase_orders, :group_id, :integer
  	end

  	def self.down
		remove_column :purchase_orders, :group_id
  	end
end
