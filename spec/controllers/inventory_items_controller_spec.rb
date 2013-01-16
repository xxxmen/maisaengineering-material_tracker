require File.dirname(__FILE__) + '/../spec_helper'

describe InventoryItemsController do
  fixtures :inventory_items
  
  before(:each) do
    login_as(:bp)
    Basket.stub!(:for_employee).and_return(Basket.new)
  end
  
  it "should list items on /inventory_items" do
    get :index
    assigns[:inventory_items].should_not be_nil
    response.should be_success
  end
  
  it "should render a new form on /inventory_items/new" do
    get :new
    assigns[:inventory_item].should be_new_record
    response.should be_success
  end
  
  it "should create an item for valid attributes on POST /inventory_items" do
    lambda { post :create, :inventory_item => valid_inventory_item }.should change(InventoryItem, :count).by(1)
    response.should redirect_to(:action => :index)
  end
  
  it "should not create an item for invalid attributes on POST /inventory_items" do
    lambda { post :create, :inventory_item => valid_inventory_item(:stock_no_id => 10, :warehouse_name => "") }.should change(InventoryItem, :count).by(0)
    response.should render_template(:edit)
    flash[:error].should_not be_nil
    flash[:notice].should be_nil
  end
  
  it "should update an item for valid attributes on PUT /inventory_items/id" do
    item = create_inventory_item(:stock_no_id => 10, :description => "Old Description")
    put :update, :id => item.id, :inventory_item => valid_inventory_item(:stock_no_id => 10, :description => "New Description")
    
    item.reload
    item.description.should == "New Description"
    response.should redirect_to(:action => :index)
    flash[:notice].should_not be_nil
  end
  
  it "should not update an item for invalid attributes on PUT /inventory_items/id" do
    item = create_inventory_item(:stock_no_id => 10, :description => "Old Description")
    put :update, :id => item.id, :inventory_item => valid_inventory_item(:stock_no_id => nil, :description => "New Description")
    
    item.reload
    item.description.should == "Old Description"
    response.should render_template(:edit)
    flash[:error].should_not be_nil
    flash[:notice].should be_nil
  end
  
end
