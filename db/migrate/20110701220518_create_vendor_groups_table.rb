class CreateVendorGroupsTable < ActiveRecord::Migration
  	def self.up
  		create_table :vendor_groups do |t|
			t.string :name
			t.timestamps  			
		end
  	end

  	def self.down
  		drop_table :vendor_groups
  	end
end
