class CreateInventoryItems < ActiveRecord::Migration
  def self.up
    create_table :inventory_items do |t|
    	    # Warehouse Information
  		t.column "warehouse_name", 			:string,   :limit => 50
          # Stock Information
  		t.column "stock_no_id", 	        :integer
  		t.column "stock_no", 				:string,   :default => "Untitled", :limit => 30	
  		t.column "description",				:string,   :default => "Untitled", :limit => 75		
  		t.column "unit_of_measure",         :string,   :default => "Each", :limit => 50		
  		t.column "picture_path",       :string, :limit => 255
          # Levels
  		t.column "consignment_count",		:decimal,  :default => nil
  		t.column "high_level",				:decimal,  :default => nil
  		t.column "low_level",				:decimal,  :default => nil
  		t.column "on_hand",					:decimal,  :default => nil
  		t.column "target_level", 			:decimal,  :default => nil
  		t.column "total_count", 			:decimal,  :default => nil
  		t.column "reordered_qty",			:decimal,  :default => nil
  		t.column "requested_reorder_at",	:datetime, :default => nil
  		t.column "date_counted",			:datetime, :default => nil
          # Vendor Info		
  		t.column "vendor_name", 			:string,   :default => "Untitled", :limit => 80
  		t.column "vendor_no", 				:string,   :default => "Untitled", :limit => 40
  		t.column "vendor_part_no", 			:string,   :default => "Untitled", :limit => 40
          # Booleans
  		t.column "consumable",				:boolean,  :default => false
  		t.column "rented",					:boolean,  :default => false
  		t.column "record_weight",			:boolean,  :default => false
          # Rates
  		t.column "daily_rate",				:float,    :default => nil
  		t.column "hourly_rate",				:float,    :default => nil
  		t.column "monthly_rate",			:float,    :default => nil
  		t.column "weekly_rate", 			:float,    :default => nil
  		t.column "last_purchase_price",		:float,    :default => nil
          # Location
  		t.column "aisle",					:string,   :default => "Untitled", :limit => 12
  		t.column "bin",						:string,   :default => "Untitled", :limit => 12
  		t.column "shelf", 					:string,   :default => "Untitled", :limit => 12
          # Timestamps
  		t.column "created_at",				:datetime
  		t.column "updated_at", 			    :datetime      
    end
  end

  def self.down
    drop_table :inventory_items
  end
end
