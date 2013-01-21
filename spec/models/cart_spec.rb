require File.dirname(__FILE__) + '/../spec_helper'

# Returns a valid instance of a Cart object
def cart(attributes = {})
  attributes.reverse_merge!(:employee_id => 1)
  return Cart.new(attributes)
end

# Takes hashes and inputs and spits out a cart for each one
def create_carts(*args)
  carts = []
  args.each do |attributes|
    cart = cart(attributes)
    cart.save
    carts << cart
  end
  
  return carts
end

describe Cart do
  fixtures :employees
	
  it "should be valid given a employee_id" do
    cart().should be_valid
    cart(:employee_id => nil).should_not be_valid
  end
  
  it "should have three states: PROCESSING, SENT, and RECEIVED" do
    # processing means the user is still working on the form
    # sent means the user is done and sent it to the local side
    # received means local side got it, printed out a copy
    Cart::PROCESSING.should == 0
    Cart::SENT.should == 1
    Cart::RECEIVED.should == 2
  end
  
  it "should have a default year and requester" do
    cart().year.should == Date.today.year
    cart(:employee_id => 99).requested_by_id.should == 99
  end
  
  it "should have immediate times for options for need_by" do
    options = ['', '30 Minutes', '1 Hour', '2 Hours', '3 Hours', '4 Hours']
    options = options.map { |opt| [opt, opt] }   # duplicate array for <% options_for_select %> format
    Cart.need_by_opts.should == options
  end
  
  it "should list all sent/issued and received/closed carts" do
    # SENT == ISSUED and RECEIVED == CLOSED
    processing, sent, received = create_carts({:state => Cart::PROCESSING},
                                              {:state => Cart::SENT}, {:state => Cart::RECEIVED})
    
    results = Cart.list_issued_or_closed.to_a
    results.should_not include(processing)
    results.should include(sent)
    results.should include(received)
  end  
  
  it "should filter carts for the index page" do
    # all, created_me, mine, submitted, received
    processing, mine, not_mine, sent, received = create_carts({:state => Cart::PROCESSING}, 
                                {:state => Cart::SENT}, { :employee_id => 2, :state => Cart::SENT }, 
                                {:state => Cart::SENT}, {:state => Cart::RECEIVED})
    me = Employee.find(1)  # Employee 1 is ME!
        
    # should get 'ALL' web requests, which is everything that's not currently in processing state
    results = Cart.filter(me, {}, 'all').to_a.map(&:id).sort
    results.should == [mine, not_mine, sent, received].map(&:id).sort
    
    # should get all web requests created by me, that's not currently in proessing
    results = Cart.filter(me, {}, 'created_me').to_a.map(&:id).sort
    results.should == [mine, sent, received].map(&:id).sort
    
    # should get all web requests requested by me that's not currently in processing
    results = Cart.filter(me, {}, 'mine').to_a.map(&:id).sort
    results.should == [mine, sent, received].map(&:id).sort
    
    # should show all 'SENT' web requests
    results = Cart.filter(me, {}, 'submitted').to_a.map(&:id).sort
    results.should == [mine, not_mine, sent].map(&:id).sort
    
    # should show all 'RECEIVED' web requests
    results = Cart.filter(me, {}, 'received').to_a.map(&:id).sort
    results.should == [received.id]
  end
  
  it "should filter carts for the index page with specific unit or requester" do
    mine_no_unit, not_mine_with_unit, mine_with_unit = create_carts({:state => Cart::SENT, :requested_by_id => 1},
            {:state => Cart::SENT, :unit_id => 1, :requested_by_id => 2}, {:state => Cart::SENT, :requested_by_id => 1, :unit_id => 1})
    me = Employee.find(1)   # We're currently logged in as the first employee
    
    results = Cart.filter(me, {}, 'all').to_a.map(&:id).sort
    results.should == [mine_no_unit, not_mine_with_unit, mine_with_unit].map(&:id).sort
    
    results = Cart.filter(me, {:unit => 1}, 'all').to_a.map(&:id).sort
    results.should == [not_mine_with_unit, mine_with_unit].map(&:id).sort
    
    results = Cart.filter(me, {:requester => 1}, 'all').to_a.map(&:id).sort
    results.should == [mine_no_unit, mine_with_unit].map(&:id).sort
    
    results = Cart.filter(me, {:unit => 1, :requester => 1}, 'all').to_a.map(&:id).sort
    results.should == [mine_with_unit.id]
  end
  
  it "should return all units in the carts table" do
    create_carts({:unit_id => 1}, {:unit_id => 2}, {:unit_id => 1})
    result = Cart.all_units.map(&:id).sort
    expected = Cart.find(:all, :select => "distinct(unit_id)").map(&:unit_id).delete_if {|id| id.blank? }.sort
    result.should == expected
  end
  
  it "should return all requesters in the carts table" do
    create_carts({:requested_by_id => 1}, {:requested_by_id => 2}, {:requested_by_id => 2})
    result = Cart.all_requesters.map(&:id).sort
    expected = Cart.find(:all, :select => "distinct(requested_by_id)").map(&:requested_by_id).delete_if { |id| id.blank? }.sort
    result.should == expected
  end
  
  it "should return the newest tracking # available" do
    create_carts({:tracking_no => "WR00001"}, {:tracking_no => "WR00004"})
    result = Cart.newest_tracking
    result.should == "WR00005"
  end
  
  it "should return the description of its unit if one exists" do
    unit = Unit.find(:first)
    cart(:unit_id => unit.id).unit_description.should == unit.description
    cart().unit_description.should == ""
  end
  
  it "should return the requester's name and ID if needed" do
    requester = Employee.find(:first)
    cart(:requested_by_id => requester.id).requester_name.should == requester.entire_full_name
    cart(:requested_by_id => requester.id).requester_name(true).should == requester.entire_name_with_id
  end
  
  it "should create a cart item if it doesn't exist or simply add to the quantity if it does exist" do
    me = Employee.find(1)
    item_1, item_2 = InventoryItem.find(:all, :limit => 2).map(&:id)
    my_cart = cart({:requested_by_id => me.id})
    my_cart.save
    my_cart.cart_items.count.should == 0
        
    cart_item = my_cart.create_or_add(:quantity => 1, :inventory_item_id => item_1)
    cart_item.should be_valid
    my_cart.cart_items.count.should == 1
    
    my_cart.create_or_add(:quantity => 5, :inventory_item_id => item_2)
    my_cart.cart_items.count.should == 2
    
    my_cart.create_or_add(:quantity => 10, :inventory_item_id => item_2)
    my_cart.cart_items.count.should == 2
    my_cart.cart_items[1].quantity.should == 15
  end
  
  it "should determine if it needs purchasing" do
    has_stock = cart()
    no_stock = cart()
    
    first_item = InventoryItem.find(:first)
    second_item = InventoryItem.find(:first, :conditions => ["id != ?", first_item.id])
    
    first_item.should_not be_blank
    second_item.should_not be_blank
    
    has_stock.create_or_add(:quantity => first_item.quantity_available, :inventory_item_id => first_item.id)
    has_stock.create_or_add(:quantity => second_item.quantity_available, :inventory_item_id => second_item.id)
    
    no_stock.create_or_add(:quantity => first_item.quantity_available + 1, :inventory_item_id => first_item.id)
    no_stock.create_or_add(:quantity => second_item.quantity_available, :inventory_item_id => second_item.id)
    
    has_stock.should_not be_out_of_stock
    no_stock.should be_out_of_stock
  end
  
  it "should use the first line item as the main description" do
    item = InventoryItem.find(:first)
    request = cart()

    request.description.should be_blank
    request.create_or_add(:quantity => 1, :inventory_item_id => item.id)
    request.description.should == item.description
  end
  
  it "should turn a cart into a material request via 'send_as_material_request'" do
    web_request = cart(:unit_id => 1, :requested_by_id => 1, :telephone => "858-627-9710", :notes => "NOTE FIELD", :deliver_to => "ME")
    item = InventoryItem.find(:first)
    web_request.create_or_add(:quantity => 1, :inventory_item_id => item.id)
    
    material_request = web_request.send_as_material_request
    material_request.class.should == MaterialRequest
    %w(unit_id requested_by_id telephone notes deliver_to).each do |attribute|
      material_request.send(attribute).should == web_request.send(attribute)
    end
    
    # the drafted//created fields should be the same as web request's employee info
    material_request.drafted_by.should == web_request.employee.id
    material_request.created_by.should == web_request.employee.id
  end
  
  it "should either create a manual request or change cart's state to SENT with 'send_request'" do
    has_stock = cart(:unit_id => 1)
    has_stock.save
    item = InventoryItem.find(:first, :conditions => "on_hand > 0 OR consignment_count > 0")
    
    has_stock.create_or_add(:quantity => item.quantity_available, :inventory_item_id => item.id)
    has_stock.send_request
    has_stock.should be_sent
    has_stock.employee.last_cart.should_not == has_stock   # current cart should no longer be has_stock
    
    no_stock = cart(:unit_id => 1)
    no_stock.save
    no_stock.create_or_add(:quantity => item.quantity_available + 1, :inventory_item_id => item.id)
    result = no_stock.send_request
    no_stock.cart_items.count.should == 0
    result.class.should == MaterialRequest
  end
end
