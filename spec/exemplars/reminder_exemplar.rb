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

class Reminder < ActiveRecord::Base
    
    generator_for :email_to do
        user = 'test'
        domain = 'domain.com'
        emails = []
        5.times do |i|
            emails << user.succ + '@' + domain
        end
        emails.join(', ')
    end

    generator_for :send_reminder_on, Date.today

    
end

