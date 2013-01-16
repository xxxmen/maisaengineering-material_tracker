class MaterialRequestsRemoveOldPipingFields < ActiveRecord::Migration
  	def self.up
  		remove_column :material_requests, :size
  		remove_column :material_requests, :klass
  		remove_column :material_requests, :component
  	end

  	def self.down
  		add_column :material_requests, :size, :string
  		add_column :material_requests, :klass, :string
  		add_column :material_requests, :component, :string
  	end
end
