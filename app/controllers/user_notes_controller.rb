class UserNotesController < SextController
  RESOURCE = UserNote
  
  before_filter :is_popv_admin, :except => [:index, :show, :create]
  
  
  def create
=begin  	
  	if !Employee.current_employee.email.blank?
        RequestMailer.send_as_html('generic',
        	:subject => "[BP Material Tracker - POPV] User Note Submitted",
	        :body => "Thank you for submitting your note: " ,  
	        :message => params[:message], 
	        :to => Employee.current_employee.email,
	        :from => Employee.current_employee.email)
    end
    
=end
      super(false)
  end
  
  def note_approved
  	
  end
  
  def note_reviewed
  	
  end
  
end
