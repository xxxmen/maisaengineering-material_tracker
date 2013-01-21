class AddDescriptionToMaterialRequest < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :description, :text
  end

  def self.down
    remove_column :material_requests, :description
  end
end
