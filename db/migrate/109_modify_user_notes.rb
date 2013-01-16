class ModifyUserNotes < ActiveRecord::Migration
	def self.up
		add_column :user_notes, :status, :string
		add_column :user_notes, :hidden, :boolean, :default => 0, :null => false
		add_column :user_notes, :original_resource_name, :string
		add_column :user_notes, :original_resource_title, :string
		add_column :user_notes, :reason, :string
		
		rename_column :user_notes, :created_by, :submitted_by
		rename_column :user_notes, :acknowledged_by, :reviewed_by
		
		remove_column :user_notes, :declined_by
		remove_column :user_notes, :implemented_by
		
		
	end
	
	def self.down
		remove_column :user_notes, :status
		remove_column :user_notes, :hidden
		remove_column :user_notes, :original_resource_name
		remove_column :user_notes, :original_resource_title
		remove_column :user_notes, :reason
		
		rename_column :user_notes, :submitted_by, :created_by
		rename_column :user_notes, :reviewed_by, :acknowledged_by
		
		add_column :user_notes, :declined_by, :integer
		add_column :user_notes, :implemented_by, :integer
	end
	
end
	