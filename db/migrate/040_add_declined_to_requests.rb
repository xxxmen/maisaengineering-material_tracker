class AddDeclinedToRequests < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :declined, :boolean
  end

  def self.down
    remove_column :material_requests, :declined
  end
end
