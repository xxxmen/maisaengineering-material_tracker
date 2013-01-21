class AddRequestedToBill < ActiveRecord::Migration
	def self.up
		add_column :bills, :material_request_id, :integer
	end
	
	def self.down
		remove_column :bills, :material_request_id
		
	end
	
end
	