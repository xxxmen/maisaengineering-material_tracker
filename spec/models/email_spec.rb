require File.dirname(__FILE__) + '/../spec_helper'

#  employee_id :integer(11)   
#  content     :text          
#  to          :text          
#  from        :text          
#  subject     :text          
#  created_at  :datetime      


describe Email do
  it "should be valid given content, to field, from field, subject, and an employee" do
    email = Email.new
    email.content = "Email content"
    email.to = "hugh@telaeris.com"
    email.from = "hugh@telaeris.com"
    email.subject = "An email I am sending to myself"
    email.employee_id = 1
    email.should be_valid
  end
  
  it "should not be valid with a missing content, to field, from field, subject, or employee" do
    email = Email.new
    email.should_not be_valid
    
    [:content, :to, :from, :subject].each do |field|
      email.should have(1).error_on(field)
    end
    
    email.employee_id.should == 1 # gets set to 1 by default, which is BP
  end
end
