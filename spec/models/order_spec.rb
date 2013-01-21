require File.dirname(__FILE__) + '/../spec_helper'

# models
# be_valid
# have_errors(:attribute => num or string)

# controllers
# create(:order), create(:order => attributes)
# update(1, :order), update(1, :order => attributes)
# destroy(1, :order)

matcher :validate_presence_of => "ValidationSpecHelper" do |errors, klass, attribute|
  errors.failure = "expected #{klass.to_s} to validate the presence of #{attribute}, but it doesn't"
  errors.negative = "expected #{klass.to_s} to not validate the presence of #{attribute}, but it doesn't"
  
  instance = klass.new(attribute.keys.first => attribute.values.first)
  instance.valid?
  instance.errors.invalid?(attribute.keys.first)
end

describe Order do        
  include CustomMatcher
  include ValidationSpecHelper
    
  before(:each) do
    @order = Order.new
  end    
    
  it "should have this matcher test be okay" do
    order = new_order(:unit_id => nil, :po_no => nil)
    order.should be_invalid
    
    Order.should validate_presence_of(:unit_id => nil)
  end

  it "should fail validation on duplicate po_no" do
    create_order(:po_no => "192010")
    @order = new_order(:po_no => "192010")

    @order.should have(1).error_on(:po_no)
  end

  it "should fail validations without a tracking, or unit_id" do
    @valid = new_order
    @po_no = new_order(:po_no => nil)
    @tracking = new_order(:tracking => nil)
    @unit = new_order(:unit_id => nil)
    
    @valid.should be_valid
    @po_no.should have(0).error_on(:po_no) # gets assigned after_save
    @tracking.should have(1).error_on(:tracking)
    @unit.should have(1).error_on(:unit_id)
  end
    
  it "should list all orders whose line item was received today for 'pos_received_today'" do
    first, second, third = create_order, create_order(:po_no => 1), create_order(:po_no => 2)
    first.ordered_line_items.create(:date_received => 1.day.ago, :description => "None", :quantity_ordered => "1")
    second.ordered_line_items.create(:date_received => Date.today, :description => "None", :quantity_ordered => "1")
    third.ordered_line_items.create(:date_received => Date.today, :description => "None", :quantity_ordered => "1")
    
    orders = Order.pos_received_today
    orders.size.should == 2
    orders.should_not include(first)
    orders.should include(second)
    orders.should include(third)
  end
  
  it "should get all orders whose line item was received during this week for 'pos_received_this_week'" do
    first, second, third = create_order, create_order(:po_no => 1), create_order(:po_no => 2)
    first.ordered_line_items.create(:date_received => 8.days.ago, :description => "None", :quantity_ordered => "1")
    second.ordered_line_items.create(:date_received => 6.days.ago, :description => "None", :quantity_ordered => "1")
    third.ordered_line_items.create(:date_received => Date.today, :description => "None", :quantity_ordered => "1")
    
    orders = Order.pos_received_this_week
    orders.size.should == 2
    orders.should_not include(first) 
    orders.should include(second) 
    orders.should include(third)
  end
  
  it "should get all orders whose line item was received during this month for 'pos_received_this_month'" do
    first, second, third = create_order, create_order(:po_no => 1), create_order(:po_no => 2)
    first.ordered_line_items.create(:date_received => 2.months.ago, :description => "None", :quantity_ordered => "1")
    second.ordered_line_items.create(:date_received => 28.days.ago, :description => "None", :quantity_ordered => "1")
    third.ordered_line_items.create(:date_received => Date.today, :description => "None", :quantity_ordered => "1")
    
    orders = Order.pos_received_this_month
    orders.size.should == 2
    orders.should_not include(first)
    orders.should include(second) 
    orders.should include(third)
  end
  
  it "should list all line items received today for 'items_received_today'" do
    @order = create_order
    3.times do
      @order.ordered_line_items.create(:date_received => Date.today, :description => "None", :quantity_ordered => "1")
    end
    @order.items_received_today.size.should == 3
  end
      
  it "should not automatically load a created date if it already exists" do
    yesterday = create_order(:created => 1.day.ago.to_date)
    today = create_order(:created => nil, :po_no => "V12-132")
        
    yesterday.created.should == 1.day.ago.to_date
    today.created.should == Date.today.to_date
  end
end