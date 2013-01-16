class RemindersController < ApplicationController
    layout "layouts/application"
  
    def index
        list
    end
  
    
    def search
        do_search
        if @reminders.size == 0
          flash[:error] = "There were no search results for <span style='color: red;'>'#{params[:q]}'</span>"
          redirect_to reminders_path and return
        elsif @reminders.size == 1
          flash.now[:notice] = "Found 1 reminder"
        else
          flash.now[:notice] = "<div id='result_msg'>Found #{@reminders.size} results for <span style='color: orangered;'>'#{params[:q]}'</span>
          <a href='#' onclick=\"$('refine').toggle(); $('refine').down('input').focus(); $('result_msg').hide(); \">Filter Results</a></div>"
        end
        render :action => :index
    end
    
    private
    
    def list
        @reminders = Reminder.list_reminders(params, :order => "reminders.send_reminder_on", :sort => 'ASC')
    end
    
    
    def do_search
        @reminders = Reminder.search_reminders(params)
    end
end
