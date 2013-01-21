class QuoteItemsAddVendorPartNumberField < ActiveRecord::Migration
  	def self.up
  		add_column :quote_items, :vendor_part_number, :string
  	end

  	def self.down
  		remove_column :quote_items, :vendor_part_number
  	end
end
