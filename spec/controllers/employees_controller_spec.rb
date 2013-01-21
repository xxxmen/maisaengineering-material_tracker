require File.dirname(__FILE__) + '/../spec_helper'

describe EmployeesController do
  fixtures :employees
  before(:each) do
   	login_as(:bp); @me = Employee.find(1); 
  end

  it "should render successfully" do
    get :index
    response.should be_success
    
    get :search, :q => ""
    response.should be_redirect    
    
    get :new
    response.should be_success
    assigns[:employee].class.should == Employee
  end  
end
