class ModifyBoms < ActiveRecord::Migration
	def self.up
		#these should be referenced from the piping_class_detail
		add_column :bills, :description, :text
		remove_column :bill_items, :pipe_class_id
	    remove_column :bill_items, :pipe_comp_id
	    rename_column :bill_items, :pipe_subcomp_id, :piping_subcomp_id
	    rename_column :bill_items, :pipe_class_details_id, :piping_class_detail_id
	end
	
	def self.down
		remove_column :bills, :description
	    add_column :bill_items, :pipe_class_id, :integer
	    add_column :bill_items, :pipe_comp_id, :integer
	    rename_column :bill_items, :piping_subcomp_id, :pipe_subcomp_id
	    rename_column :bill_items, :piping_class_detail_id, :pipe_class_details_id
	end
	
end
	