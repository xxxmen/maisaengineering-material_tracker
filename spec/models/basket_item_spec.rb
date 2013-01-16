require File.dirname(__FILE__) + '/../spec_helper'

# Takes a basket_item and sets all the fields so that the basket_item
# will pass validation
def validate_basket_item(basket_item)
  basket_item.basket_id = 1
  basket_item.inventory_item_id = 1
  basket_item.quantity = 1
  basket_item.should be_valid
  
  return basket_item
end

describe BasketItem do
  it "should be invalid without a basket_id" do
    basket_item = BasketItem.new(:basket_id => nil)
    basket_item.should_not be_valid
    basket_item.should have(1).error_on(:basket_id)
    
    validate_basket_item(basket_item)
  end
  
  it "should be invalid without a inventory_item_id" do
    basket_item = BasketItem.new(:inventory_item_id => nil)
    basket_item.should_not be_valid
    basket_item.should have(1).error_on(:inventory_item_id)

    validate_basket_item(basket_item)
  end
  
  it "should be invalid without a numeric quantity" do
    basket_item = BasketItem.new(:quantity => nil)
    basket_item.should_not be_valid
    basket_item.should have(2).errors_on(:quantity)
    
    basket_item.quantity = "String"
    basket_item.should_not be_valid
    basket_item.should have(1).error_on(:quantity)
    
    validate_basket_item(basket_item)
  end
end