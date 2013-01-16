class PipingClassDetailsChangeDescription < ActiveRecord::Migration
	def self.up
  		change_column :piping_class_details, :description, :text
  	end

  	def self.down
  	end
end
