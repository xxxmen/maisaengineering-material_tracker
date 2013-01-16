class AddExtPriceAndTotalToQuote < ActiveRecord::Migration
  def self.up
    add_column :quote_items, :ext_price, :decimal, :precision => 16, :scale => 2
    add_column :quotes, :total_price, :decimal, :precision => 16, :scale => 2
  end

  def self.down
    remove_column :quote_items, :ext_price
    remove_column :quotes, :total_price
  end
end
