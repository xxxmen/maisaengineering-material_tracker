class CreateVendorBillItems < ActiveRecord::Migration
  def self.up
    create_table :vendor_bill_items do |t|
      t.integer :bill_id
      t.integer :bill_item_id
      t.integer :vendor_id
      t.text :notes
      t.string :price
      t.date :availability
    end
    
    add_column :bills, :notes, :text
  end

  def self.down
    drop_table :vendor_bill_items
    remove_column :bills, :notes
  end
end
