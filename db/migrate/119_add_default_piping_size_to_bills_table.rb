class AddDefaultPipingSizeToBillsTable < ActiveRecord::Migration
    def self.up
        add_column :bills, :default_piping_size, :string 
    end

    def self.down
        remove_column :bills, :default_piping_size
    end
end
