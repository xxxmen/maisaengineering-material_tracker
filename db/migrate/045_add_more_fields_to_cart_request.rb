class AddMoreFieldsToCartRequest < ActiveRecord::Migration
  def self.up
    add_column :carts, :requested_by_id, :integer
    add_column :carts, :state, :integer, :default => 0
  end

  def self.down
    remove_column :carts, :requested_by_id
    remove_column :carts, :state
  end
end
