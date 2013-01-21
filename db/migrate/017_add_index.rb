class AddIndex < ActiveRecord::Migration
  def self.up
    add_index :purchase_orders, :created
    add_index :ordered_line_items, [:po_id, :line_item_no]
  end

  def self.down
    remove_index :purchase_orders, :created
    remove_index :ordered_line_items, [:po_id, :line_item_no]
  end
end
