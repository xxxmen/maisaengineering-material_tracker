require File.dirname(__FILE__) + "/../spec_helper"

describe InventoryItem do  
  it "should be invalid without a warehouse_name or stock_no_id" do
    no_id = create_inventory_item(:stock_no_id => nil)
    no_name = create_inventory_item(:stock_no_id => 10, :warehouse_name => nil)
    blank_name = create_inventory_item(:stock_no_id => 10, :warehouse_name => "")
    neither = create_inventory_item(:stock_no_id => nil, :warehouse_name => nil)
    
    # All four items should be invalid
    no_id.should_not be_valid
    no_name.should_not be_valid
    blank_name.should_not be_valid
    neither.should_not be_valid
    
    # Needs a stock_no_id
    no_id.should have(1).error_on(:stock_no_id)
    
    # Needs a warehouse_name
    no_name.should have(1).error_on(:warehouse_name)
    blank_name.should have(1).error_on(:warehouse_name)
    
    # Invalid without either
    neither.should have(1).error_on(:stock_no_id)
    neither.should have(1).error_on(:warehouse_name)
  end
  
  it "should create a new inventory item with a new unit of measure" do
    item = InventoryItem.create(:warehouse_name => "JOE DOE", :stock_no_id => 0, :unit_of_measure => "testing")
  end
end