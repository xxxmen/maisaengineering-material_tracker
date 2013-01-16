class AddFieldsToQuotes < ActiveRecord::Migration
  def self.up
    add_column :quote_items, :price, :double, :precision => 16, :scale => 2
    add_column :quote_items, :date_available, :date
  end

  def self.down
    remove_column :quote_items, :price
    remove_column :quote_items, :date_available
  end
end
