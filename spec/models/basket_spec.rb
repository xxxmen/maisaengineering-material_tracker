require File.dirname(__FILE__) + '/../spec_helper'

describe Basket do
  fixtures :employees
  
  it "should require an employee_id" do
    basket = Basket.new
    basket.should_not be_valid
    basket.should have(1).error_on(:employee_id)
    
    basket.employee_id = 1
    basket.should be_valid
  end
  
  it "should delete any basket items when it gets deleted" do
    basket = Basket.new
    basket.employee_id = 1
    basket.save
    
    basket.basket_items.create!(:quantity => 1, :inventory_item_id => 1)
    Basket.count.should == 1
    BasketItem.count.should == 1
    
    basket.destroy
    Basket.count.should == 0
    BasketItem.count.should == 0
  end
  
  it "should always be available to an employee via for_employee" do
    employee = Employee.find(:first)
    Basket.count.should == 0
    
    basket = Basket.for_employee(employee)
    Basket.count.should == 1
    
    basket_again = Basket.for_employee(employee)
    basket.should == basket_again
  end
end