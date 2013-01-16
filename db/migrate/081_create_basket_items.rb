class CreateBasketItems < ActiveRecord::Migration
  def self.up
    create_table "basket_items" do |t|
      t.integer :basket_id
      t.integer :inventory_item_id
      t.integer :quantity

      t.timestamps 
    end
  end

  def self.down
    drop_table "basket_items"
  end
end
