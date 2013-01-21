class RelateMaterialRequestToCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :material_request_id, :integer
  end

  def self.down
    remove_column :carts, :material_request_id
  end
end
