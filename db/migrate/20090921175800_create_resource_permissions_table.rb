class CreateResourcePermissionsTable < ActiveRecord::Migration
  	def self.up
  		create_table :resource_permissions, :force => true do |t|
  			t.string :name
  			t.boolean :enabled, :default => false
  			
  			t.timestamps	
 		end
  	end

  	def self.down
  		drop_table :resource_permissions
  	end
end
