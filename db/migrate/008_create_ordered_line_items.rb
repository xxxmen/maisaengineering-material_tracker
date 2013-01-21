class CreateOrderedLineItems < ActiveRecord::Migration
  def self.up
    create_table :ordered_line_items, :primary_key => "id" do |t|
      t.column :po_id, :int
      t.column :line_item_no, :int
      t.column :description, :text
      t.column :quantity_ordered, :int
      t.column :quantity_received, :int
      t.column :item_price, :decimal
      t.column :date_received, :date, :default => nil
      t.column :date_back_ordered, :date, :default => nil
      t.column :notes, :text
      t.column :lock_version, :int, :default => 0
      t.column :updated_at, :datetime
      t.column :dirty, :int
     end
     
  end

  def self.down
    drop_table :ordered_line_items
  end
end
