class CreatePipingReferencesTable < ActiveRecord::Migration

  	def self.up
  	    create_table "piping_references" do |t|
	      	t.string    "data_file_name"
	      	t.string    "data_content_type"
	      	t.integer   "data_file_size"
	      	t.integer   "attachings_count", :default => 0
	      	t.datetime  "data_updated_at"
	      	t.string    "reference_type"
      		t.string    "description"
      		t.string    "custom_link"
      		t.boolean   "show_public_link", :default => false
	      	t.datetime  "created_at"
      		t.datetime  "updated_at"
      		t.integer   "created_by"
      		t.integer   "updated_by"
	    end
	    
	    create_table "piping_reference_attachings" do |t|
      	    t.integer  "piping_reference_id"
	      	t.integer  "attachable_id"
	      	t.string   "attachable_type"
	      	t.datetime "created_at"
	      	t.datetime "updated_at"
	    end
    
    	add_index "piping_reference_attachings", ["piping_reference_id"], :name => "index_piping_reference_attachings_on_piping_reference_id"
    	add_index "piping_reference_attachings", ["attachable_id"], :name => "index_piping_reference_attachings_on_attachable_id"
	end
  
  	def self.down
      	drop_table :piping_references
      	drop_table :piping_reference_attachings
  	end
end
