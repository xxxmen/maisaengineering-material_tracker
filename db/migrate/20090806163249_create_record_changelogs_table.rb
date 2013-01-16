class CreateRecordChangelogsTable < ActiveRecord::Migration
  	def self.up
  		create_table :record_changelogs, :force => true do |t|
  			t.string 	:record_type
  			t.integer 	:record_id
  			t.string	:field_name
  			t.text		:old_value
  			t.text		:new_value
  			t.datetime	:modified_at
  			t.integer 	:employee_id
  			t.datetime 	:created_at
  			t.datetime 	:updated_at
 		end
  	end

  	def self.down
  		drop_table :record_changelogs
  	end
end
