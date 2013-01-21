class UpdateRecordChangelogs < ActiveRecord::Migration
  	def self.up
  		remove_column :record_changelogs, :employee_id
  		remove_column :record_changelogs, :record_id
  		add_column :record_changelogs, :record_identifier, :string
  		add_column :record_changelogs, :action, :string
  		add_column :record_changelogs, :modified_by, :string
  		add_column :record_changelogs, :comment, :text
  	end

  	def self.down
  		add_column :record_changelogs, :employee_id, :integer
  		add_column :record_changelogs, :record_id, :integer
  		remove_column :record_changelogs, :record_identifier
  		remove_column :record_changelogs, :action
  		remove_column :record_changelogs, :modified_by
  		remove_column :record_changelogs, :comment
  	end
end
