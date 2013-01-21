require File.dirname(__FILE__) + '/../spec_helper'

describe CartItemsController do
  fixtures :carts, :cart_items, :employees
  before(:each) { login_as(:bp); @me = Employee.find(1); }  
  
  it "should create a cart if necessary and add or create an item" do
    cart = @me.last_cart
    cart.destroy
    item = InventoryItem.find(:first)
    
    post :create, :cart_item => { :quantity => 1, :inventory_item_id => item.id }
    cart = @me.last_cart
    cart.cart_items.count.should == 1
    cart.cart_items[0].inventory_item_id.should == item.id
    cart.cart_items[0].quantity.should == 1
    
    post :create, :cart_item => { :quantity => 2, :inventory_item_id => item.id }
    assigns[:cart_item].should be_valid
    cart.cart_items.count.should == 1
    cart.reload
  end
  
  it "should update a cart item with new values" do
    cart_item = CartItem.find(:first)
    cart_item.should_not be_blank
    
    put :update, :id => cart_item.id, :cart_item => {:quantity => 5}
    cart_item.reload
    cart_item.quantity.should == 5
    
    put :update, :id => cart_item.id, :cart_item => {:quantity => 6}
    cart_item.reload
    cart_item.quantity.should == 6
  end
  
  it "should remove a cart item" do
    cart_item = CartItem.find(:first)
    cart_item_id = cart_item.id
    
    delete :destroy, :id => cart_item_id
    CartItem.find_by_id(cart_item_id).should be_nil
  end
end