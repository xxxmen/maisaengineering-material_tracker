class ModifyPipingClasses < ActiveRecord::Migration
  def self.up
    
  	add_column :piping_classes, :consequence_of_failure, :string
  	change_column :piping_classes, :comments, :text
  	change_column :piping_classes, :special_note, :text
  	change_column :piping_classes, :maintenance_note, :text
  	
  	#remove_column :piping_class_details, :piping_description_id
  	#remove_column :piping_class_details, :piping_specification_id
  	
  	#add_column :piping_class_details, :description, :text
  	add_column :piping_class_details, :description_detail, :text
  	
  	add_column :piping_notes, :note_number, :integer
  	
  	
  end

  def self.down
  	remove_column :piping_classes, :consequence_of_failure
  	change_column :piping_classes, :comments, :string
  	change_column :piping_classes, :special_note, :string
  	change_column :piping_classes, :maintenance_note, :string
  	
  	#remove_column :piping_class_details, :description
  	remove_column :piping_class_details, :description_detail
  	
  	#add_column :piping_class_details, :piping_description_id, :integer
  	#add_column :piping_class_details, :piping_specification_id, :integer
  	
  	remove_column :piping_notes, :note_number
  end
end
