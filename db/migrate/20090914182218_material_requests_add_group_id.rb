class MaterialRequestsAddGroupId < ActiveRecord::Migration
	def self.up
		add_column :material_requests, :group_id, :integer
  	end

  	def self.down
		remove_column :material_requests, :group_id
  	end
end
