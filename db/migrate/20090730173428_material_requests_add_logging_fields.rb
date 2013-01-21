class MaterialRequestsAddLoggingFields < ActiveRecord::Migration
  	def self.up
  		add_column :material_requests, :created_at, :datetime
  		add_column :material_requests, :updated_by, :integer
  	end

  	def self.down
  		remove_column :material_requests, :created_at
  		remove_column :material_requests, :updated_by
  	end
end
