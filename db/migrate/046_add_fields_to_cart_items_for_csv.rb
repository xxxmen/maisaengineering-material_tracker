class AddFieldsToCartItemsForCsv < ActiveRecord::Migration
  def self.up
    add_column :carts, :tracking_no, :string
    add_column :carts, :stage_location, :string
    add_column :carts, :date_requested, :date
    add_column :cart_items, :notes, :text
  end

  def self.down
    remove_column :carts, :tracking_no
    remove_column :carts, :stage_location
    remove_column :carts, :date_requested
    remove_column :cart_items, :notes
  end
end
