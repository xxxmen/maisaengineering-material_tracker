require File.dirname(__FILE__) + '/../spec_helper'

def do_post(attrs = {})
  post :create, :order => valid_order(attrs)
end

def all_actions(controller)
  reject_methods = []
  controller.public_instance_methods(false).reject { |action| reject_methods.include?(action) }
end

describe OrdersController do
  fixtures :employees, :purchase_orders, :units
  
  before(:each) do
    login_as(:francdl)
  end
  
  it "should render /index on GET to index" do
    get :index
    response.should be_success                                                                                                                                                                                                                                                                                         
    response.should render_template("index") 
    
    change_role(Employee::REQUESTING)
    get :index, :order_by => "tracking"
    response.should be_success
  end
  
  it "should render /edit on GET to 1;edit" do
    get :edit, :id => 1
    response.should be_success 
    response.should render_template("edit") 
    assigns[:order].id.should == 1
  end
  
  it "should render /new on GET to new" do
    get :new
    response.should be_success 
    response.should render_template("edit")
    assigns[:order].should be_new_record 
    assigns[:order].tracking.should == nil
  end
  
  it "should create a new order on POST to create" do
    lambda { do_post }.should change(Order, :count).by(1)
  end
  
  it "should automatically assign a tracking # to fresh orders" do
    tracking = Order.newest_tracking
    do_post(:tracking => nil)
    assigns[:order].tracking.should == tracking
  end
  
  it "should not assign a tracking is POST gave a tracking attribute" do
    tracking = Order.newest_tracking
    do_post
    assigns[:order].tracking.should_not == tracking
  end
  
  it "should redirect to the new order on POST to create" do
    post :create, :order => valid_order
    response.should be_redirect
  end
  
  it "should render the edit_line_items template on GET to edit_line_items" do
    get :edit_line_items, :id => 1
    response.should be_success
    response.should render_template("edit_line_items") 
  end
  
  it "should render a new add_line_items table on GET to add_line_item" do
    get :add_line_item, :id => 1
    # response.should have_rjs(:insert_html, :bottom, "line_items_table", :partial => :line_item_fields, :locals => { :ordered_line_item => OrderedLineItem.new(:line_item_no => 1)} )   
  end    
end

describe OrdersController, "updating /orders/1 with a PUT" do
  integrate_views
  fixtures :employees, :purchase_orders
  
  def do_put(attributes = {})
    put :update, :id => 1, :order => { :description => "New Description" }.merge(attributes)
  end
  
  before(:each) do
    login_as(:francdl)
    PoStatus.stub!(:fully_received_id).and_return(1)
    do_put
  end
  
  it "should update the order successfully" do
    order = Order.find(1)
    order.description.should == "New Description"
  end
  
  it "should redirect to orders edit on success" do
    response.should be_redirect
    response.should redirect_to(edit_order_path(1)) 
  end
  
  it "should re-render the form with message on error" do
    do_put(:po_no => Order.find(2).po_no)
    response.should be_success 
    response.should render_template(:edit)
  end
  
  it "should not create a new line item on update" do
    lambda { do_put }.should_not change(OrderedLineItem, :count)
  end
end
