require File.dirname(__FILE__) + '/../spec_helper'

describe EmailsController do

  it "should display the correct email" do
    email = Email.create!(:to => "hugh@telaeris.com", :from => "hugh@telaeris.com", :subject => "Hello!", :content => "Hello World!")
    get :show, :id => email.id
    response.should be_success
    assigns[:email].should == email
    assigns[:content].should == email.content
  end

end
