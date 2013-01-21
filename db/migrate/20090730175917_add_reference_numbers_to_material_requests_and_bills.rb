class AddReferenceNumbersToMaterialRequestsAndBills < ActiveRecord::Migration
  	def self.up
  		add_column :material_requests, :reference_number_type, :string
  		add_column :material_requests, :reference_number, :string
  		
  		add_column :bills, :reference_number_1_type, :string
  		add_column :bills, :reference_number_1, 		:string
  		add_column :bills, :reference_number_2_type, :string
  		add_column :bills, :reference_number_2, 		:string
  		add_column :bills, :reference_number_3_type, :string
  		add_column :bills, :reference_number_3, 		:string
  	end

  	def self.down
  		remove_column :material_requests, :reference_number_type
  		remove_column :material_requests, :reference_number
  		
  		remove_column :bills, :reference_number_1_type
  		remove_column :bills, :reference_number_1
  		remove_column :bills, :reference_number_2_type
  		remove_column :bills, :reference_number_2
  		remove_column :bills, :reference_number_3_type
  		remove_column :bills, :reference_number_3
  	end
end
