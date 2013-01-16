require File.dirname(__FILE__) + '/../spec_helper'

describe MaterialRequest do
  fixtures :material_requests, :units, :employees
  
  it "should have a few default fields for new records" do
    req = MaterialRequest.new
    req.date_need_by.should == 3.days.from_now.to_date
    req.year.should == Date.today.year
  end
  
  it "should automagically save a tracking number" do
    tracking = MaterialRequest.newest_tracking
    
    req = MaterialRequest.new
    req.items.build(:material_description => "New Line Item")
    req.save
    req.tracking.should == tracking
  end
  
  it "should find all requests for the current requester and no more" do
    hugh = create_employee(:role => Employee::REQUESTING)        
    3.times do |i|
      req = hugh.material_requests.build(valid_request.merge({:tracking => "L#{i}"})) 
      req.items.build(:material_description => "line_item")
      req.save!
    end
    hugh.material_requests.count.should == 3
    
    results = MaterialRequest.for_employee(hugh, :q => "id", :p => 1)
    expected = MaterialRequest.find(:all, :order => :id, 
                                          :page => { :size => MaterialRequest::PERPAGE, :current => 1 }, 
                                          :conditions => {:requested_by_id => hugh.id})
    
    results.size.should == expected.size
    results.each do |request|
      expected.should include(request)
    end
  end
  
  it "should have many items as requested_line_items" do
    @material_request = MaterialRequest.new
    @material_request.should respond_to(:items)
  end  
end

describe MaterialRequest, "initialized with valid attributes" do
  fixtures :material_requests, :units, :employees
  
  before(:each) do
    @material_request = MaterialRequest.new(valid_request)
    @material_request.items.build(:material_description => "test")
  end

  it "should be valid" do
    @material_request.should be_valid
  end
  
  it "should use 3 days in advance for 'date_need_by'" do
    @material_request.date_need_by.should == 3.days.from_now.to_date
  end
  
  it "should not set 'date_need_by' if it is not a new record" do
    @material_request.date_need_by = nil
    @material_request.save!
    
    MaterialRequest.find(@material_request.id).date_need_by.should == nil
  end
  
  it "should not set 'date_need_by' if the value is already given as an attribute" do
    date = 1.week.ago
    @material_request = MaterialRequest.new(:date_need_by => date)
    @material_request.date_need_by.should == date
  end
  
  it "should update with line items" do
    @material_request.items.destroy_all
    params = {}
    params[:material_request] = valid_request
    params[:items] = { 1 => { :material_description => "first" }, 
                       2 => { :material_description => "second" } }
    @material_request.update_with_items(params[:material_request], params[:items])
    @material_request.items.size.should == 2
    @material_request.should be_valid
    
    @material_request.save!
    @material_request.should_not be_new_record
    @material_request.items.each do |i|
      i.should_not be_new_record
    end
  end
  
  it "should set the acknowledged_by field" do
    @material_request.current_employee_id = 1
    @material_request.acknowledged = 1
    @material_request.valid?

    @material_request.current_employee_id.should == 1
    @material_request.acknowledged_by.should == 1
  end
  
  it "should set the authorized_by field" do
    @material_request.current_employee_id = 1
    @material_request.authorized = "1"
    @material_request.valid?

    @material_request.current_employee_id.should == 1
    @material_request.authorized_by.should == 1
  end
    
  it "should should not set the acknowledged_by, authorized_by, or stage_at field" do
    @material_request.current_employee_id = 1
    @material_request.acknowledged = "0"
    @material_request.authorized = "0"
    @material_request.valid?
    
    @material_request.acknowledged_by.should be_nil
    @material_request.authorized_by.should be_nil
  end
end

describe MaterialRequest, "with invalid attributes" do
end

describe MaterialRequest, "given a relationship" do
  fixtures :material_requests, :units, :employees
  
  before(:each) do
    @material_request = new_request
    @material_request.items.build(:material_description => "New Line Item", :quantity => 1)
  end
  
  it "should be invalid if its unit does not exist" do
    @material_request.unit_id = 500
    @material_request.should_not be_valid
    @material_request.should have(1).error_on(:unit)
    
    @material_request.unit_id = nil
    @material_request.should_not be_valid
  end
  
  it "should be invalid if the employee does not exist" do
    @material_request.requested_by_id = 500
    @material_request.planner_id = 500
    @material_request.should_not be_valid
    @material_request.should have(1).error_on(:planner)
    @material_request.should have(1).error_on(:requester)
    
    @material_request.planner_id = nil
    @material_request.requested_by_id = nil
    @material_request.should_not be_valid
  end
end
