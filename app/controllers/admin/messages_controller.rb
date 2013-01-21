class Admin::MessagesController < ApplicationController
	before_filter :admin_required
	
	def new_admin_message
		@message = Admin::Message.new
		if request.post?
			if params[:commit] == 'Delete Message'
				Admin::Message.delete_all
				flash[:notice] = "Message has been deleted."
				redirect_to '/admin/new_message' and return
			end
			if @message.update_attributes(params[:message])
				flash[:notice] = "Your new message will appear starting #{@message.get_start_time} until #{@message.get_end_time}"
				redirect_to '/admin/new_message'
			else
				flash[:error] = "There was a problem with your message: #{@message.errors.full_messages.join(', ')}"
			end
		end
	end
	
	private
	
	def admin_required
		unless current_employee.admin?
			flash[:error] = "This page could not be accessed."
			redirect_to '/'
		end
	end
end
