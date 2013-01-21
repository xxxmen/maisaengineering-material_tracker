class AddDeletedToMaterialRequest < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :deleted, :boolean, :default => false
    MaterialRequest.update_all(["deleted = ?", false])
  end

  def self.down
    remove_column :material_requests, :deleted
  end
end
