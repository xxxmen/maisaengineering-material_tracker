class AddActivityToMaterialRequests < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :activity, :text
  end

  def self.down
    remove_column :material_requests, :activity
  end
end
