class CreateVendorGroupsVendorsJoinTable < ActiveRecord::Migration
    def self.up
        create_table :vendor_groups_vendors, :id => false do |t|
            t.integer :vendor_id
            t.integer :vendor_group_id
        end
    end

    def self.down
        drop_table :vendor_groups_vendors
    end
end
