class ExtendBoms < ActiveRecord::Migration
	def self.up
	    # Better Names
	    rename_column :bills, "employee_id", "created_by" 
	    rename_column :bills, "notes", "special_instructions" 
	    
	    # Needed in BOM Form    
		add_column :bills, :tracking,            :string
		add_column :bills, :work_order,          :string
		add_column :bills, :required_on,         :date
		add_column :bills, :suggested_vendor,    :string      # NOT A FOREIGN KEY!!!
		add_column :bills, :delivery_type,       :string      # Limit to (default) NORMAL, ASAP, EXPEDITE
		add_column :bills, :unit_id,             :integer     # foreign key to units
		add_column :bills, :process,             :string
		add_column :bills, :mes,                 :string
		add_column :bills, :updated_by,          :integer     # foreign key to employees
		
		# I don't think these will be used here	
		remove_column :bills, :approved_by_id
		remove_column :bills, :reviewed_by_id
		remove_column :bills, :approved      
		remove_column :bills, :reviewed      
		remove_column :bills, :requested     
			
	end
	
	def self.down
	    rename_column :bills, "created_by", "employee_id"
	    rename_column :bills, "special_instructions", "notes"
	    
		remove_column :bills, :tracking
		remove_column :bills, :work_order
		remove_column :bills, :required_on
		remove_column :bills, :suggested_vendor   
		remove_column :bills, :delivery_type           
		remove_column :bills, :unit_id               
		remove_column :bills, :process
		remove_column :bills, :mes
		
		remove_column :bills, :updated_by
		
		add_column :bills, :approved_by_id, :integer
		add_column :bills, :reviewed_by_id, :integer
		add_column :bills, :approved,       :boolean
		add_column :bills, :reviewed,       :boolean
		add_column :bills, :requested,      :boolean 

	end
	
end

