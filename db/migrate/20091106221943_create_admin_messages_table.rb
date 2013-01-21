class CreateAdminMessagesTable < ActiveRecord::Migration
  	def self.up
  		create_table :admin_messages, :force => true do |t|
			t.string :text
			t.datetime :display_until_time
			
			t.timestamps  			
		end
  	end

  	def self.down
  		drop_table :admin_messages
  	end
end
