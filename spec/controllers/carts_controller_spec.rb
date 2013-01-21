require File.dirname(__FILE__) + '/../spec_helper'

describe CartsController do
  fixtures :inventory_items, :carts, :cart_items
  before(:each) { login_as(:bp); @me = Employee.find(1); }  
  
  it "should find the first cart whose status is SENT" do
    Cart.find(:all).each { |c| c.update_attributes!(:state => Cart::RECEIVED) }
    get :get_order
    response.should_not be_success
    
    cart = Cart.find(:first)
    cart.update_attributes!(:state => Cart::SENT, :employee_id => 1, :requested_by_id => 1, :unit_id => 1)
    get :get_order
    response.should be_success
    
    get :get_order
    response.should_not be_success
  end
  
  it "should return the edit form" do
    cart = Cart.find(:first)
    get :edit, :id => cart.id
    response.should be_success
    assigns[:cart].should == cart
  end
  
  it "should re-submit a cart to warehouse" do
    cart = Cart.find(:first)
    cart.update_attributes!(:state => Cart::RECEIVED)
    get :resend, :id => cart.id
    
    response.should be_redirect
    cart.reload
    cart.received_at.should be_blank
    cart.should be_sent
    cart.should_not be_received
    
    get :resend, :id => cart.id
    response.should be_redirect
    flash[:message].should == "Cart has not been received by Warehouse yet"
  end
  
  it "should be successful on a few requests" do
    get :index
    response.should be_success
    assigns[:cart].should == @me.last_cart
  	
	# Seems like a pointless test that Hugh wrote... (Adam Grant, 6/30/09)
	# So I added this:
  	InventoryItem.stub!(:search).and_return([])
    get :search, :q => ""
    response.should be_redirect
  end
  
  it "should clear out the cart" do
    cart = Cart.find(:first)
    item = InventoryItem.find(:first)
    cart_item = cart.create_or_add(:quantity => 1, :inventory_item_id => item.id)
    cart.cart_items.should include(cart_item)
    
    delete :destroy, :id => cart.id
    cart.reload
    cart.cart_items.size.should == 0
  end
  
  it "should delete the cart from the database" do
    cart = Cart.find(:first)
    cart_id = cart.id
    
    delete :delete, :id => cart_id
    Cart.find_by_id(cart_id).should be_nil
  end
  
  it "should update the employee's current cart" do
    get :index
    cart = @me.last_cart
    cart.update_attributes!(:unit_id => 2, :state => Cart::PROCESSING)
    
    put :update, :cart => { :unit_id => 1 }, :commit => "Save and Add More Items"
    response.should be_redirect
    cart.reload
    cart.unit_id.should == 1
    cart.should be_processing
        
    # Submitting a cart with reasonable quantity
    cart.cart_items.each { |i| i.destroy }
    item = InventoryItem.find(:first, :conditions => "consignment_count > 0")
    cart.create_or_add(:quantity => item.quantity_available, :inventory_item_id => item.id)
    cart.should be_processing
    put :update, :cart => {}, :commit => "Submit Request To Warehouse"
    response.should be_redirect
    cart.reload
    cart.should be_sent
    
    # Submitting a cart with quantity overflow should create a new material request
    material_request_count = MaterialRequest.count
    cart = @me.last_cart
    cart.update_attributes!(:unit_id => 1, :state => Cart::PROCESSING)
    cart.cart_items.each { |i| i.destroy }
    cart.create_or_add(:quantity => item.quantity_available + 1, :inventory_item_id => item.id)
    cart.should be_processing
    put :update, :cart => {}, :commit => "Submit Request To Warehouse"
    response.should be_redirect
    MaterialRequest.count.should == material_request_count + 1
  end
  
end
