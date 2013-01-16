require File.dirname(__FILE__) + '/../spec_helper'

describe PipingComponent, "When creating, editing, or deleting records" do

	before(:each) do
		Employee.stub!(:current_employee_id).and_return(5)
		RecordChangelog.disable_recording {
			@piping_component = PipingComponent.generate(:piping_component => "Some Component", :display_seq_no => 1)
		}
	end
	
	it "should record two changes before update" do
		RecordChangelog.should_receive(:record_changes).once
		@piping_component.piping_component = "Some Other Component"
		@piping_component.display_seq_no = 2
		@piping_component.save
	end
	
	it "should fail to destroy if there are associated piping_class_details" do
		@piping_component.piping_class_details.generate
		lambda { @piping_component.destroy }.should raise_error(ActiveRecord::ActiveRecordError)
	end
	
	it "should destroy all associations to user_notes" do
		UserNote.generate(:table_type => 'PipingComponent', :table_id => @piping_component.id, :note => 'Test Note')
		UserNote.count.should == 1
		@piping_component.user_notes.count.should == 1
		@piping_component.destroy
		UserNote.count.should == 0
	end

	it "should fail to destroy if subcomponents are associated" do
		@piping_component.subcomponents.generate(:piping_component => 'Wrench')
		lambda { @piping_component.destroy }.should raise_error(ActiveRecord::ActiveRecordError)
	end

end

describe PipingComponent do

	before(:each) do
		Employee.stub!(:current_employee_id).and_return(5)
		@piping_component = PipingComponent.generate(:piping_component => "Some Component")
		@piping_class = PipingClass.generate(:class_code => 'SA')
		PipingClassDetail.generate(:piping_class => @piping_class, :piping_component => @piping_component)
		@piping_class_2 = PipingClass.generate(:class_code => 'ABC')
		PipingClassDetail.generate(:piping_class => @piping_class_2, :piping_component => @piping_component)
	end
	
	it "should get an array of all piping class codes associated to this component" do
		@piping_component.get_related_piping_classes.should == 'ABC, SA'
	end
end
