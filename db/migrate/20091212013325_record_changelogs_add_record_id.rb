class RecordChangelogsAddRecordId < ActiveRecord::Migration
  	def self.up
  		add_column :record_changelogs, :record_id, :integer
  	end

  	def self.down
  		remove_column :record_changelogs, :record_id
  	end
end
