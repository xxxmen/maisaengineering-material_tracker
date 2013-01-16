class AddPurchaserToRequests < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :purchaser_id, :integer
  end

  def self.down
    remove_column :material_requests, :purchaser_id
  end
end
