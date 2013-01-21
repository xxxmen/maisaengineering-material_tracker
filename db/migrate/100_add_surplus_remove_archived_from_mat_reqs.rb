class AddSurplusRemoveArchivedFromMatReqs < ActiveRecord::Migration
    def self.up
        remove_column :material_requests, :archived
        add_column :material_requests, :surplus, :boolean, :default => false
    end

    def self.down
        add_column :material_requests, :archived, :boolean, :default => false
        remove_column :material_requests, :surplus
    end
end
