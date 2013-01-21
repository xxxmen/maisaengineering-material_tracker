class CreateGeneralReferencesTable < ActiveRecord::Migration
    # == Schema Information
    # Schema version: 20090730175917
    #
    # Table name: refs
    #
    #  id           :integer(4)    not null, primary key
    #  parent_id    :integer(4)    
    #  content_type :string(255)   
    #  filename     :string(255)   
    #  size         :integer(4)    
    #  folder_id    :integer(4)    
    #  search_terms :text          
    #  created_at   :datetime      
    #  updated_at   :datetime      
    #
    class Reference < ActiveRecord::Base
        set_table_name :refs
        # Must have attachment_fu to use this feature!
        has_attachment :storage => :file_system,
                       :path_prefix => "refs"
    end
    
    def self.up
    	create_table :general_references, :force => true do |t|
			t.string    :reference_file_name
			t.string    :reference_content_type
			t.integer   :reference_file_size
			t.datetime  :reference_updated_at
			t.datetime  :created_at
			t.datetime  :updated_at
   		end
   		
   		references = Reference.find(:all)
   		
   		references.each do |ref|
   		    file = File.new(ref.public_filename, 'r')
   		
   		    GeneralReference.create({
   		        :reference => file
   		    })
	    end
	    drop_table :refs
    end

    def self.down
    	drop_table  :general_references
    end
end
