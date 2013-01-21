require File.dirname(__FILE__) + '/../spec_helper'

describe ValveComponent, "When modifying attributes and field values" do

	it "should record two changes before update" do
    	Employee.stub!(:current_employee_id).and_return(5)
    	@valve_component = ValveComponent.generate(:component_name => "Some Component", :order_numbering => 1)
		@valve_component.component_name = "Some Other Component"
		@valve_component.order_numbering = 2
		@valve_component.save
		RecordChangelog.count.should == 2
	end

end

