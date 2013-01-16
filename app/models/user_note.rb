# == Schema Information
# Schema version: 20090730175917
#
# Table name: user_notes
#
#  id                      :integer(4)    not null, primary key
#  table_type              :string(255)   
#  table_id                :string(255)   
#  table_field_name        :string(255)   
#  table_field_data        :string(255)   
#  note                    :text          
#  submitted_by            :integer(4)    
#  reviewed_by             :integer(4)    
#  created_at              :datetime      
#  updated_at              :datetime      
#  status                  :string(255)   
#  hidden                  :boolean(1)    not null
#  original_resource_name  :string(255)   
#  original_resource_title :string(255)   
#  reason                  :string(255)   
#

class UserNote < ActiveRecord::Base
  
  belongs_to :bill, :polymorphic => true
  belongs_to :piping_class, :polymorphic => true
  belongs_to :piping_class_detail,:polymorphic => true
  belongs_to :piping_note,:polymorphic => true
  belongs_to :piping_component,:polymorphic => true
  belongs_to :valve_detail, :polymorphic => true
  #belongs_to :piping_subcomponent, :polymorphic => true
  belongs_to :piping_specification, :polymorphic => true
  belongs_to :piping_description, :polymorphic => true
  belongs_to :valve, :polymorphic => true
  belongs_to :valves_valve_component, :polymorphic => true
  belongs_to :manufacturer, :polymorphic => true
  belongs_to :manufacturers_valve,:polymorphic => true
  belongs_to :valve_component, :polymorphic => true
  
  belongs_to :submitting_user, {:class_name => 'Employee', :foreign_key => 'submitted_by'}
  belongs_to :reviewing_user, {:class_name => 'Employee', :foreign_key => 'reviewed_by'}
  before_save :fix_table_type
  before_save :set_status
  before_create :set_submitted_by_and_status
  
    SEXT_INCLUDE = [:submitting_user, :reviewing_user]
 def set_submitted_by_and_status
	self.submitted_by = Employee.current_employee_id
	self.status = "Not Reviewed"
 	self.reviewed_by = nil
 	RequestMailer.send_as_html("note_submitted", self)
 end
 
 def set_status
 	
 	if(self.status == "Approved") || (self.status == "Rejected")
 		self.reviewed_by = Employee.current_employee_id
 		
 		RequestMailer.send_as_html("note_reply", self)
 	else
 		self.status = "Not Reviewed"
 		self.reviewed_by = nil	
 	end
 end
 
 
  def sext_data(options = {})
  	json = super()
  	json[:submitting_user] = self.submitting_user ? self.submitting_user.entire_full_name : ''
  	json[:reviewing_user] = self.reviewing_user ? self.reviewing_user.entire_full_name : ''
  	json[:reason] = self.reason || ''
  	return json
  end
  
    def class_as_string(str)
  	if(Module.const_get(str))
  		return true
  	else
  		return false
  	end
  	rescue Exception => ex
  		return false
  end
  
  def fix_table_type

  	if(class_as_string(self.table_type) == false)
  		#we originally pass in just the resource_name
  		#we want to save this value for later, to open the resource
  		self.table_type = self.table_type.to_s.singularize.camelcase
  	end
  	
  	#convert odd names
  	#Piping should be PipingClass
  	if(self.table_type == "Piping")
  		self.table_type = "PipingClass"
  	end
  	#PipingClassDetail###### should be PipingClassDetail
  	if(self.table_type =~ /PipingClassDetail/)
  		self.table_type = "PipingClassDetail"
  	end
  	
  	
  end
end
