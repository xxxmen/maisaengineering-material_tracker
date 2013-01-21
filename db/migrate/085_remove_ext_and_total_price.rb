class RemoveExtAndTotalPrice < ActiveRecord::Migration
  def self.up
    remove_column :quotes, :total_price
    remove_column :quote_items, :ext_price
  end

  def self.down
    add_column :quotes, :total_price, :decimal, :precision => 16, :scale => 2
    add_column :quote_items, :ext_price, :decimal, :precision => 16, :scale => 2
  end
end
