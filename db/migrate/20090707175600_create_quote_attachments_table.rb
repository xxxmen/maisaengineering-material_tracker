class CreateQuoteAttachmentsTable < ActiveRecord::Migration
    
    # Defines the old class so we can strip it out of the app/models directory.
    # It cannot be seen by other classes unless the call is prefixed with it's namespace.
	class Asset < ActiveRecord::Base
		# t.integer "parent_id"
		# t.string  "content_type"
		# t.string  "filename"
		# t.string  "thumbnail"
		# t.integer "size"
		# t.integer "width"
		# t.integer "height"
		# t.string  "assetable_type"
		# t.integer "assetable_id"
		
        # Must have attachment_fu to use this feature!
	  	has_attachment :storage => :file_system, :path_prefix => "assets"
		belongs_to :assetable, :polymorphic => true               
	end
	
    def self.up
        # Creates the replacement table for assets
    	create_table :quote_attachments, :force => true do |t|
    		t.integer   :quote_id
			t.string    :attachment_file_name
			t.string    :attachment_content_type
			t.integer   :attachment_file_size
			t.datetime  :attachment_updated_at
   		end
   		
   		# Migrate the actual records and files
        assets = Asset.all
		assets.each do |old|
			file = File.new(old.public_filename, 'r')
			QuoteAttachment.create({
			    :quote_id => old.assetable_id,
				:attachment => file
			})
		end
		
		# Drop the table
   		drop_table :assets    	
    end

    def self.down
    	drop_table  :quote_attachments
    	create_table "assets", :force => true do |t|
 		    t.integer "parent_id"
 		    t.string  "content_type"
 		    t.string  "filename"
 		    t.string  "thumbnail"
 		    t.integer "size"
 		    t.integer "width"
 		    t.integer "height"
 		    t.string  "assetable_type"
 		    t.integer "assetable_id"
 		end
    end
end

