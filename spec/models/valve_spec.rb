require File.dirname(__FILE__) + '/../spec_helper'

describe Valve, "When modifying attributes and field values" do

	it "should record two changes before update" do
    	Employee.stub!(:current_employee_id).and_return(5)
    	@valve = Valve.generate(:valve_code => "Some Code 1", :valve_note => "Some Note 1")
		@valve.valve_code = "Some Code 2"
		@valve.valve_note = "Some Note 2"
		@valve.save
		RecordChangelog.count.should == 2
	end

end

