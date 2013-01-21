require File.dirname(__FILE__) + '/../spec_helper'

def setup_basket_for(user)
  basket = Basket.for_employee(user)
  inventory_item = InventoryItem.find(:first)
  basket.basket_items.create!(:quantity => 1, :inventory_item => inventory_item)
  
  return basket
end

describe BasketsController do
  fixtures :employees, :inventory_items
  before(:each) { login_as(:bp); @user = employees(:Bp); }
  
  it "should add a basket item to the current employee's basket" do
    basket = Basket.for_employee(@user)
    inventory_item = InventoryItem.find(:first)
    
    basket.basket_items.size.should == 0
    post :add_item, :basket_item => { :quantity => 1, :inventory_item_id => inventory_item.id }
    basket.reload
    basket.basket_items.size.should == 1
  end
  
  it "should remove a basket item from the current employee's basket" do
    basket = setup_basket_for(@user)    
    basket.basket_items.size.should == 1
    
    basket_item = basket.basket_items[0]
    post :del_item, :basket_item_id => basket_item.id
    basket.reload
    basket.basket_items.size.should == 0
  end
  
  it "should clear out the current employee's basket" do
    basket = setup_basket_for(@user)
    basket.basket_items.size.should == 1
    
    post :delete, :id => basket.id
    basket.reload
    basket.basket_items.size.should == 0
  end
end