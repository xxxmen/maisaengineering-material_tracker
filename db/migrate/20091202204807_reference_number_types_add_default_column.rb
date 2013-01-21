class ReferenceNumberTypesAddDefaultColumn < ActiveRecord::Migration
  	def self.up
  		add_column :reference_number_types, :default, :boolean, :default => false
  	end

  	def self.down
  		remove_column :reference_number_types, :default
  	end
end
