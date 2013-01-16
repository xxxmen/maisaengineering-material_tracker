class CreatePurchaseOrders < ActiveRecord::Migration
  def self.up
    # From the ACCESS table:
    # Lowercase all letters of the field
    # Substitute all spaces with underscores
    # Substitute all pound signs ('#') with "_no"
    # Get rid of all ampersands ('&') and single quotes (')
    # Substitute foward slashes ('/') with underscores
    # FIXME: change to purchase_orders
    create_table "purchase_orders", :primary_key => "id" do |t|
      t.column "created", :date
      t.column "tracking", :text
      t.column "po_no", :text
      t.column "description", :text
      t.column "vendor_id", :int
      t.column "status_id", :int, :default => 1
      t.column "deliver_to", :string
      t.column "work_orders", :string
      t.column "ptm_no", :text
      t.column "awr", :boolean, :default => false
      t.column "total_cost", :decimal, :precision =>  16, :scale => 2
      t.column "unit_id", :int
      t.column "turnaround_year", :text
      t.column "date_eta", :date, :default => nil
      t.column "completed", :boolean, :default => false      
      t.column "closed", :boolean, :default => false
      t.column "location", :text
      t.column "activity", :text
      t.column "issued_to_history", :text
      t.column "lock_version", :int, :default => 0
      t.column "updated_at", :datetime      
      t.column :dirty, :int
      t.column :record_counter, :int
    end   
  end

  def self.down
    drop_table "purchase_orders"
  end
end
