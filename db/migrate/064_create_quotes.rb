class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.integer :material_request_id
      t.integer :vendor_id
      t.text :notes

      t.timestamps 
    end
  end

  def self.down
    drop_table :quotes
  end
end
