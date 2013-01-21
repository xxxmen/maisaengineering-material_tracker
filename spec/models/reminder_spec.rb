require File.dirname(__FILE__) + '/../spec_helper'

# == Schema Information
# Schema version: 121
#
# Table name: reminders
#
#  id               :integer(11)   not null, primary key
#  po_id            :integer(11)   
#  email_to         :text          
#  send_reminder_on :date          
#  notes            :text          
#  created_by       :integer(11)   
#
#
#    t.integer  "po_id"
#    t.text     "email_to"
#    t.date     "send_reminder_on"
#    t.text     "notes"
#    t.integer  "created_by"
#    t.datetime "sent_on"


describe Reminder, "When mass emailing all the purchase order reminders for the day" do
  
    def setup_email
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []
    end
    
    before(:each) do
        setup_email
		PoStatus.generate(:status => 'Fully Received')
        @po_status = PoStatus.generate(:status => 'Ordered')
        @emails = ["a@x.com", "a@x.com, b@x.com", "b@x.com"]
        @pos = ["L000", "L100", "L200"]
        3.times do |i|
            @order = Order.generate(:po_no => @pos[i], :status_id => @po_status.id)
            Reminder.generate(:send_reminder_on => (Date.today - i), 
                                      :email_to => @emails[i], 
                                      :order => @order)
        end
        
        Reminder.generate(:send_reminder_on => (Date.today + 1), :email_to => @emails)
        Reminder.generate(:send_reminder_on => (Date.today + 4), :email_to => @emails)
    end


    it "should send 3 reminders in 2 emails" do        
        Reminder.find_all_to_be_sent_today
        reminder_emails = Reminder.email_reminders_for_today
        
        ActionMailer::Base.deliveries.size.should == 2
        reminder_emails[0].body.should =~ /L000/
        reminder_emails[0].body.should =~ /L100/
        reminder_emails[1].body.should =~ /L100/
        reminder_emails[1].body.should =~ /L200/
    end
    
    
    it "should set emailed reminders' sent_on field to current date" do
        Reminder.find_all_to_be_sent_today.size.should == 3
        Reminder.email_reminders_for_today
        Reminder.find_all_to_be_sent_today.size.should == 0
    end
     
    it "should update related orders" do
        reminder_emails = Reminder.email_reminders_for_today
        @pos.each_index do |i|
            order = Order.find_by_po_no(@pos[i])
            order.activity.should_not be_blank
            order.activity.should == "* REMINDER TO #{@emails[i]} SENT ON #{Date.today.to_s(:long)}"
        end
    end
     

end
