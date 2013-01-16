# == Schema Information
# Schema version: 20090730175917
#
# Table name: reminders
#
#  id               :integer(4)    not null, primary key
#  po_id            :integer(4)    
#  email_to         :text          
#  send_reminder_on :date          
#  notes            :text          
#  created_by       :integer(4)    
#  sent_on          :datetime      
#  updated_at       :datetime      
#

class Reminder < ActiveRecord::Base
	
  ##############################################################################
  # MODULES
  
    extend Listable::ModelHelper
    
  ##############################################################################
  # CONSTANTS
    PERPAGE = 100

  ##############################################################################
  # ASSOCIATIONS
  
    belongs_to :order, :foreign_key => 'po_id'
    belongs_to :creator, :foreign_key => 'created_by', :class_name => 'Employee'

  ##############################################################################
  # CALLBACKS
  
    before_create :save_creator

  ##############################################################################
  # VALIDATIONS
  
    validates_uniqueness_of :po_id, :scope => [:email_to, :send_reminder_on]

  ##############################################################################
  # CLASS METHODS
    
    def self.list_reminders(params, options = {})
        Reminder.list(params, { :include => [:order => [:status] ] }.merge(options))
    end
    
    def self.create_reminders_for_order(order_id, email_to, notes, params)
        order = Order.find(order_id)
        
        new_reminders = []
        date = nil
        
        created_by = Employee.current_employee ? Employee.current_employee.id : nil

        # Wrap in a transaction for easy rollback.
        self.transaction do 
            params.each_pair do |key, value|
                date = nil
            
                if key == 'date_of' && value == '1'
                    date = order.date_eta
                elsif key == 'custom_date' && !value.blank?
                    date = value
                end
            
                # Loop through all the checkboxes on the page.
                [1,2,3,4,8].each do |wk|
                    if key == "week_#{wk}_after" && value == '1'
                        date = order.date_eta + wk.weeks
                    end
                    if key == "week_#{wk}_before" && value == '1'
                        date = order.date_eta - wk.weeks
                    end
                end

                # Create a Reminder if a date was given in this loop iterance. 
                unless date.nil?
                    new_reminders << Reminder.create!(
                        :po_id => order.id, 
                        :email_to => email_to,
                        :notes => notes,
                        :send_reminder_on => date,
                        :created_by => created_by
                    )
                end
            end
        end # end of the transaction block
        
        return_msg = "No new reminders created."
        if new_reminders.size == 1
            return_msg = "Successfully created a new Reminder for this Order."
        elsif new_reminders.size > 1
            return_msg = "Successfully created #{new_reminders.size} new Reminders for this Order."
        end

        return true, return_msg
    rescue ActiveRecord::RecordInvalid => e
        logger.info e.message
        new_reminders.each {|r| r.destroy }
        return false, "Error: Could not create a Reminder for #{date.to_formatted_s(:web)}."
    end
    
    
  ##############################################################################
  # INSTANCE METHODS
    
    def self.search_reminders(params, options = {})
        filter = FilterFoo.new
        q = params[:q]
        filter.or do |f|
            f.like q, "purchase_orders.po_no"
            f.like q, "purchase_orders.tracking"
            f.like q, "reminders.email_to"
            f.like q, "reminders.notes" 
        end
        with_scope(:find => { :conditions => filter.conditions }) do
            self.list_reminders(params)
        end
    end
    
    
    ##
    #   Delivers all of the reminders scheduled for today or for previous days.
    #   The reminders are then destroyed.
    #
    #	If test == true, will send emails to only the addresses stored in 
    #	MAIL_TEST_EMAIL, defined in environment.rb
    #
    def self.email_reminders_for_today(test = false)
        sent_emails = []

        reminders = self.find_all_to_be_sent_today

        reminder_ids = reminders.map {|r| r.id }

        email_reminders_hash = self.aggregate_reminders_for_recipients(reminders)

        email_reminders_hash.each do |recipient, array_of_reminders|
        	if test
            	sent_emails << RequestMailer.deliver_order_reminders(true, MAIL_TEST_EMAIL, array_of_reminders)
           	else
            	sent_emails << RequestMailer.deliver_order_reminders(true, recipient, array_of_reminders)
           	end
        end

		unless test
	        reminder_ids.each do |i|
    	   		reminder = Reminder.find(i)
    	       	reminder.mark_as_sent
    	    end
	   	end
    #rescue => e
        #logger.error "Error marking Purchase Order reminders as sent: IDS=#{reminder_ids.inspect}\n#{e.message}\n#{e.backtrace}"
        #RequestMailer.deliver_error("Error marking Purchase Order reminders as sent: IDS=#{ids.to_s}\n#{e.message}\n#{e.backtrace}")
    #ensure
        return sent_emails
    end



    ##
    #   Finds all reminders to be sent on or before today, in case there is a
    #   backlog.
    #
    def self.find_all_to_be_sent_today
    	conditions = [""]
    	conditions[0] << "reminders.send_reminder_on <= ? AND reminders.sent_on IS NULL"
    	conditions[0] << " AND purchase_orders.status_id != ? AND purchase_orders.completed != 1 AND purchase_orders.closed != 1"
    	conditions << Date.today
    	conditions << PoStatus.fully_received_id    	
    	
        self.find(:all, {
        		  :conditions => conditions, 
        		  :order => 'send_reminder_on ASC',
        		  :include => [:order]
        })
    end
    
    
    ##
    #	Displays the reminders in an easy to read format for the console.
    #
    def self.print_reminders
    	reminders = self.find_all_to_be_sent_today
    	puts "ID\tPO_ID\tPO_NO\temail_to\t\t\tsend_reminder_on\tsent_on\tStatus"
    	reminders.each do |r|
    		puts "#{r.id}\t#{r.po_id}\t#{r.order.po_no}\t#{r.email_to}\t\t\t#{r.send_reminder_on}\t#{r.sent_on}\t#{r.order.status.status}"    		
   		end
   		nil
   	end
    
    
    ##
    #   Loops through each passed-in reminder, parses the email_to addresses,
    #   and creates a hash with email addresses as the keys, and arrays of
    #   reminders as the values.
    #   If we pass in two reminders in an array:
    #       Reminder_1.email_to = 'test@domain.com'
    #       Reminder_2.email_to = 'test@domain.com, test2@domain.com'
    #   It will create a hash like:
    #       {
    #           'test@domain.com'  => [#<Reminder_1>, #<Reminder_2>],
    #           'test2@domain.com' => [#<Reminder_2>]
    #       }
    #
    #   Basically, it groups the reminders by which email addresses they need to
    #   get sent to, so that it sends only one email with many reminders to each
    #   address. It also checks if a reminder with that same po_id has been
    #	added to the queue for that email address, in which case it won't
    #	add another reminder for that Purchase Order.
    def self.aggregate_reminders_for_recipients(reminders)
        email_hash = {}
        reminders.each do |r|
            emails = r.parse_emails
            emails.each do |e|
                if !email_hash.has_key?(e)
                    email_hash[e] = []
                end
                unless check_for_duplicate_po_ids(email_hash[e], r.po_id)
                    email_hash[e] << r
                end

            end
        end
        return email_hash
    end


    ##
    #   Parses a string like:
    #      "test@domain.com, test2@domain.com ,test3@domain.com,\r\ntest4@domain.com"
    #   into an array of email addresses, stripping off extra chars.
    #
    def parse_emails
        emails = []
        if !self.email_to.blank?
            emails = self.email_to.split(',')
            emails = emails.map {|e| e.strip }
        end
    end


    def mark_as_sent
        activity_string = "* REMINDER TO #{self.email_to} SENT ON #{Date.today.to_s(:long)}"
        self.order.update_activity(activity_string)
        self.sent_on = Date.today
        self.save!
    end


    def save_creator
        self.created_by = Employee.current_employee ? Employee.current_employee.id : nil
    end


    def subject
        self.order.reminder_subject
    end


    def order_completed?
        self.order && (self.order.completed? || self.order.closed?)
    end

  ##############################################################################
  private

	def self.check_for_duplicate_po_ids(reminders_array, po_id)
		found_duplicate = false
		reminders_array.each do |reminder|
			found_duplicate = true if reminder.po_id == po_id
		end		
		return found_duplicate
	end
	
	
end

