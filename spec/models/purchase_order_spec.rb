require File.dirname(__FILE__) + '/../spec_helper'

# This spec was created because I didn't want to deal with order_spec.rb not 
# working for some reason, and I don't have the time to track down why.
# Different filename, same class being tested! - Adam Grant (05/22/09)

describe Order, "When changing the ETA" do
	
	before(:each) do
		# Seems this version of Rails doesn't delete fixtures after each spec.
		Order.delete_all
		Unit.delete_all
	end

	it "should calculate the date change difference and store it into the instance attribute `eta_change_difference`" do
		po = Order.spawn(:date_eta => Date.today)
		po.date_eta += 1.week
		
		po.eta_change_difference.should == -7
	end

	it "should not store a value into the instance attribute `eta_change_difference` if no previous date was set" do
		po = Order.spawn(:date_eta => Date.today)
		po.date_eta.should == Date.today
		
		po.eta_change_difference.should be_blank
	end
	
	it "should update all reminders' sent_reminder_on date to reflect the date difference" do
		date = Date.today
		po = Order.generate(:date_eta => (date + 1.week))
		
		reminder_1 = Reminder.generate(:po_id => po.id, :send_reminder_on => date)
		reminder_2 = Reminder.generate(:po_id => po.id, :send_reminder_on => (date + 1.week))
		reminder_3 = Reminder.generate(:po_id => po.id, :send_reminder_on => (date + 2.week))
		
		po.date_eta -= 1.week
		po.save!
		
		[reminder_1, reminder_2, reminder_3].each {|r| r.reload }
		
		reminder_1.send_reminder_on.should == (date - 1.week)
		reminder_2.send_reminder_on.should == date
		reminder_3.send_reminder_on.should == date + 1.week
	end
	
	it "should not update any reminders' sent_reminder_on date if there was no ETA date change" do
		date = Date.today
		updated_at = (Time.now - 1.day)
		
		po = Order.generate(:date_eta => (date + 1.week))
		
		reminder_1 = Reminder.generate(:po_id => po.id, :send_reminder_on => date, :updated_at => updated_at)
		reminder_2 = Reminder.generate(:po_id => po.id, :send_reminder_on => (date + 1.week), :updated_at => updated_at)
		reminder_3 = Reminder.generate(:po_id => po.id, :send_reminder_on => (date + 2.week), :updated_at => updated_at)
		
#		reminder_1.updated_at.to_s.should == updated_at.to_s
				
		po.date_eta = (date + 1.week)
		
		reminders_array_mock = mock('reminders_array')
		reminders_array_mock.should_not_receive(:each)
		
		po.stub!(:find_upcoming_reminders).and_return(reminders_array_mock)
		
		po.save!
		
		[reminder_1, reminder_2, reminder_3].each {|r| r.reload }
		
		po.eta_change_difference.should == nil
	
		reminder_1.send_reminder_on.should == date
		reminder_2.send_reminder_on.should == date + 1.week
		reminder_3.send_reminder_on.should == date + 2.week
	end

end
