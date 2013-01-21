require File.dirname(__FILE__) + '/../spec_helper'

describe CompaniesController do
  fixtures :companies, :employees
  before(:each) { login_as(:bp); @me = Employee.find(1); }
  
  it "should render successfully" do
    get :index
    response.should be_success
    
    get :search, :q => ""
    response.should be_redirect    
  end
  
  it "should render a new company for editing" do
    get :new
    response.should be_success
    response.should render_template('edit')
    assigns[:company].class.should == Company
    assigns[:company].should be_new_record
  end
  
  it "should create a new company" do
    company_count = Company.count
    post :create, :company => valid_company
    Company.count.should == company_count + 1
    response.should be_redirect
    
    post :create, :company => invalid_company
    Company.count.should == company_count + 1
    response.should be_success # re-render form
  end
  
  it "should update a company's information" do
    company = Company.find(:first)
    put :update, :company => {:name => "New Name"}, :id => company.id
    company.reload
    company.name.should == "New Name"
    response.should be_redirect
    
    put :update, :company => { :name => nil }, :id => company.id
    response.should be_success # re-render edit form
  end
  
  it "should delete a company" do
    company = Company.find(:first)
    company_id = company.id
    
    delete :destroy, :id => company_id
    Company.find_by_id(company_id).should be_nil
  end
end
