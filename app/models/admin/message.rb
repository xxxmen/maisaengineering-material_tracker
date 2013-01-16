class Admin::Message < ActiveRecord::Base
	TIME_TO_DISPLAY = 24.hours
	
	set_table_name 'admin_messages'
	
	validates_presence_of :text, :display_until_time
	
	before_create :delete_all_messages
	
	def self.get_message
		message = find(:first, :order => 'updated_at DESC')
		if !(message.nil?)
			if message.expired?
				Admin::Message.delete_all
			end
			message = message.can_show? ? message.text : nil
		end
		message
	end
	
	
	def get_start_time
		get_start_datetime.strftime("%b %d, %I:%M%p")
	end
	
	def get_end_time
		self.display_until_time.strftime("%b %d, %I:%M%p")
	end
	
	def expired?
		self.display_until_time <= Time.now
	end
	
	def can_show?
		get_start_datetime <= Time.now
	end
	
	private
	
	def get_start_datetime
		self.display_until_time - TIME_TO_DISPLAY
	end
	
	def delete_all_messages
		Admin::Message.delete_all
	end
end
