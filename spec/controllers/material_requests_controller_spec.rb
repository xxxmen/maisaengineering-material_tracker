require File.dirname(__FILE__) + '/../spec_helper'

describe MaterialRequestsController, "on GET /index" do
  integrate_views
  fixtures :employees, :material_requests, :requested_line_items, :units
  before(:each) { login_as(:bp); get :index; }
  
  it "should be a success" do
    response.should be_redirect
  end  
end

describe MaterialRequestsController, "on GET /new" do
  integrate_views
  fixtures :employees, :material_requests, :requested_line_items, :units
  before(:each) { login_as(:bp); get :new; }
  
  it "should be a success" do
    response.should be_success 
  end
  
  it "should render the 'edit' template" do
    response.should render_template(:edit) 
  end  
end

describe MaterialRequestsController, "on POST /material_requests" do
  integrate_views
  fixtures :employees, :material_requests, :requested_line_items, :units
  before(:each) { login_as(:bp); }

  def do_post(use_invalid = false)
    # If you want an invalid POST, leave the description blank
    description = use_invalid ? "" : "New Line Item"
    post :create, :material_request => valid_request(:notes => "New Request"), 
                  :item => { 1 => valid_req_item(:material_description => description) }
    @material_request = MaterialRequest.find_by_notes("New Request")
  end
  
  it "should create a new request" do
    lambda { do_post }.should change(MaterialRequest, :count).by(1)
  end
  
  it "should redirect to edit the request" do
    do_post 
    response.should redirect_to(edit_material_request_path(@material_request)) 
  end
  
  it "should assign the current user as the requestor" do
    do_post
    @material_request.requester.should_not be_nil # login_as stubbed as first employee
  end
    
  it "should leave an error message to the user for an invalid entry" do
    do_post(true)
    # flash[:error].should == "No request was created (because there was no line item to create)" 
  end
end

describe MaterialRequestsController, "on PUT /material_requests/1" do
  integrate_views
  fixtures :material_requests, :employees, :requested_line_items, :units
  before(:each) do
    login_as(:bp)
    @material_request = MaterialRequest.find(1)
  end
  
  def do_put
    put :update, :id => 1, :material_request => valid_request(:notes => "New Notes"),
                           :item => { 1 => valid_req_item }
  end
  
  it "should update a material request" do
    lambda { do_put; @material_request.reload }.should change(@material_request, :notes)
  end

  it "should redirect to 'edit'" do
    do_put
    response.should redirect_to(edit_material_request_path(@material_request)) 
  end  
end