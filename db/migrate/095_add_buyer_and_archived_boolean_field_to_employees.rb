class AddBuyerAndArchivedBooleanFieldToEmployees < ActiveRecord::Migration
    def self.up
        add_column :employees, :buyer, :boolean, :default => false
        add_column :employees, :archived, :boolean, :default => false
    end

    def self.down
        remove_column :employees, :buyer
        remove_column :employees, :archived
    end
end
