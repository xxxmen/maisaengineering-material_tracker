class AddUnitToCarts < ActiveRecord::Migration
  def self.up
    add_column :carts, :unit_id, :integer
  end

  def self.down
    remove_column :carts, :unit_id
  end
end
