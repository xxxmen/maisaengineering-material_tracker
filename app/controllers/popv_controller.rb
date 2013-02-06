class PopvController < ApplicationController
#    before_filter :is_popv_user
  before_filter :resource_enabled?
    
    def index
    	@piping_references = PipingReference.list_public_links
    end
    
    def is_popv_user
        if(!Employee.current_employee.can_view_popv?) 
            flash[:error] = "You do not have online POPV priveleges, please contact an administrator"
            redirect_to '/' and return
        end
    end
    
    def popv_user_guide
    	filepath = File.join(Rails.root, "docs", "WebPOPV_Guide.pdf")
    	send_file(filepath)
   	end
    
    protected
    
    def authorized?
      true
    end

end
