class CreateQuoteItems < ActiveRecord::Migration
  def self.up
    create_table :quote_items do |t|
      t.integer :requested_line_item_id
      t.integer :item_no
      t.integer :quote_id
      t.integer :quantity
      t.text :notes

      t.timestamps 
    end
  end

  def self.down
    drop_table :quote_items
  end
end
