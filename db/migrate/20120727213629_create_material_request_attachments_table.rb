class CreateMaterialRequestAttachmentsTable < ActiveRecord::Migration
    def self.up
        # Creates the replacement table for assets
    	create_table :material_request_attachments, :force => true do |t|
    		t.integer   :material_request_id
			t.string    :attachment_file_name
			t.string    :attachment_content_type
			t.integer   :attachment_file_size
			t.datetime  :attachment_updated_at
   		end
   		
   		# Migrate the actual records and files
        mrs = MaterialRequest.all

		mrs.each do |mr|
			if(!mr.attachment_file_name.nil?)
				if(File.exists?(mr.attachment.path))
					file = File.new(mr.attachment.path, 'r')
					MaterialRequestAttachment.create({
					    :material_request_id => mr.id,
						:attachment => file
					})
				end
			end
		end


		remove_column :material_requests, :attachment_file_name
		
    end

    def self.down
    	drop_table  :material_request_attachments
    end
end
