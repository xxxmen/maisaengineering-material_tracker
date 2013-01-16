class AddAttachmentFileNameToMaterialRequests < ActiveRecord::Migration
    def self.up
        add_column :material_requests, :attachment_file_name, :string
    end
    
    def self.down
        remove_column :material_requests, :attachment_file_name
    end
end
