require File.dirname(__FILE__) + '/../spec_helper'

describe CartItem do
  it "should be valid given a cart_id, quantity, and inventory_item_id" do
    new_cart_item.should be_valid
  end
  
  it "should be invalid without a cart_id, or quantity, or inventory_item_id" do
    new_cart_item(:cart_id => nil).should have(1).error_on(:cart_id)
    new_cart_item(:quantity => nil).should_not be_valid
    new_cart_item(:quantity => "asdf").should_not be_valid
    new_cart_item(:quantity => 0).should_not be_valid
    new_cart_item(:quantity => "-1").should_not be_valid
    new_cart_item(:inventory_item_id => nil).should have(1).error_on(:inventory_item_id)
  end
  
  it "should return the stock_no of the inventory item" do
    new_cart_item(:inventory_item_id => nil).stock_no.should be_blank
    new_cart_item.stock_no.should == new_cart_item.inventory_item.stock_no
  end
  
end
