class NewSizesForBillItems < ActiveRecord::Migration
  def self.up
    remove_column :bill_items, :size_1_id
    remove_column :bill_items, :size_2_id
    add_column :bill_items, :size_1, :string
    add_column :bill_items, :size_2, :string
  end

  def self.down
    add_column :bill_items, :size_1_id, :integer
    add_column :bill_items, :size_2_id, :integer
    remove_column :bill_items, :size_1
    remove_column :bill_items, :size_2
  end
end
