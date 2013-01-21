class AddForeignKeyToRequestedLineItem < ActiveRecord::Migration
  def self.up
    add_column :requested_line_items, :ordered_line_item_id, :integer
  end

  def self.down
    remove_column :requested_line_items, :ordered_line_item_id
  end
end
