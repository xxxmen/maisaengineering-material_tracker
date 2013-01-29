# == Schema Information
# Schema version: 20090730175917
#
# Table name: emails
#
#  id          :integer(4)    not null, primary key
#  employee_id :integer(4)    
#  content     :text          
#  to          :text          
#  from        :text          
#  subject     :text          
#  created_at  :datetime      
#

# An email is just a record used for logging emails sent out from Material Tracker
class Email < ActiveRecord::Base  
  belongs_to :employee
  has_many :events, :as => :recordable
  
  before_validation :set_employee, :on => :create

  validates_presence_of :content, :to, :from, :subject, :employee_id
          
  private
  def set_employee
    self.employee ||= Employee.current_employee
    if self.employee_id.blank?
      self.employee_id = 1 # Set to BP (ADMIN)
    end
  end
end
