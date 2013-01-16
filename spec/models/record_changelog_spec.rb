require File.dirname(__FILE__) + '/../spec_helper'

describe RecordChangelog, "When modifying attributes and field values" do

    before(:each) do
    	Employee.stub!(:current_employee_name).and_return('Adam')
    	
    	RecordChangelog.enable_recording = false
    	@piping_class = PipingClass.generate(:class_code => "ABC")
    	RecordChangelog.enable_recording = true
    end

	it "should record changes before update" do
		@piping_class.class_code = "CBA"
		@piping_class.save
		RecordChangelog.count.should == 1
		record_changelog = RecordChangelog.first
		record_changelog.record_type.should == @piping_class.class.to_s.titleize
		record_changelog.record_identifier.should == @piping_class.record_changelog_identifier
		record_changelog.action.should == 'Updated'
		record_changelog.field_name.should == "class_code".humanize
		record_changelog.old_value.should == "ABC"
		record_changelog.new_value.should == "CBA"
		record_changelog.modified_by.should == 'Adam'
	end

	it "should record two changes before update" do
		@piping_class.class_code = "CBA"
		@piping_class.comments = "Some Comment"
		@piping_class.save
		RecordChangelog.count.should == 2
	end
end

describe RecordChangelog, "When updating associations" do

    before(:each) do
    	Employee.stub!(:current_employee_name).and_return('Adam')
    	
    	RecordChangelog.disable_recording do
        	@piping_class = PipingClass.generate(:class_code => "ABC")
	    	@piping_component = PipingComponent.generate(:piping_component => "Elbow")
	    	@valve_1 = Valve.generate(:valve_code => 'V1')
	    	@valve_2 = Valve.generate(:valve_code => 'V2')    	
	    	@piping_class_detail = PipingClassDetail.generate(
	    		:piping_class => @piping_class,
	    		:piping_component => @piping_component
	    	)
		end    	
    end
    
    describe "when there is at least one blank value" do
    	
    	before(:each) do
	    	RecordChangelog.disable_recording do
    			@piping_class_detail.valve_id = nil
    			@piping_class_detail.save   	
	   		end    
    	end
    	
    	it "should not list any value if old id is nil" do
	    	RecordChangelog.disable_recording do
    			@piping_class_detail.valve_id = nil
    			@piping_class_detail.save
	   		end
	   		@piping_class_detail.reload
	   		@piping_class_detail.valve = @valve_1
   			@piping_class_detail.save
   			
			RecordChangelog.count.should == 1
   			@record_changelog = RecordChangelog.first
   			@record_changelog.old_value.should == ""
   			@record_changelog.new_value.should == @valve_1.record_changelog_identifier
   		end

    	it "should not list any value if new id is nil" do
	    	RecordChangelog.disable_recording do
		   		@piping_class_detail.valve = @valve_1
    			@piping_class_detail.save
	   		end
	   		@piping_class_detail.reload
   			@piping_class_detail.valve_id = nil
    		@piping_class_detail.save
   			
			RecordChangelog.count.should == 1
   			@record_changelog = RecordChangelog.first
   			@record_changelog.old_value.should == @valve_1.record_changelog_identifier
   			@record_changelog.new_value.should == ""
   		end

    	it "should not balk if old id = 0" do
	    	RecordChangelog.disable_recording do
    			@piping_class_detail.valve_id = 0
    			@piping_class_detail.save
	   		end
	   		@piping_class_detail.reload
	   		@piping_class_detail.valve = @valve_1
   			@piping_class_detail.save
   			
			RecordChangelog.count.should == 1
   			@record_changelog = RecordChangelog.first
   			@record_changelog.old_value.should == "0"
   			@record_changelog.new_value.should == @valve_1.record_changelog_identifier
   		end

    	it "should not balk if new id = 0" do
	    	RecordChangelog.disable_recording do
    			@piping_class_detail.valve = @valve_1
    			@piping_class_detail.save
	   		end
	   		@piping_class_detail.reload
	   		@piping_class_detail.valve_id = 0
	   		@piping_class_detail.save
   			
			RecordChangelog.count.should == 1
   			@record_changelog = RecordChangelog.first
   			@record_changelog.old_value.should == @valve_1.record_changelog_identifier
   			@record_changelog.new_value.should == "0"
   		end
    	
   	end

end

describe RecordChangelog, "When creating new records" do

    before(:each) do
    	Employee.stub!(:current_employee_name).and_return('Adam')
    	
    	RecordChangelog.enable_recording = true
    end

	it "should record the creation of records" do
    	@piping_class = PipingClass.generate(:class_code => "ABC")
		RecordChangelog.count.should == 1
		record_changelog = RecordChangelog.first
		record_changelog.record_type.should == @piping_class.class.to_s.titleize
		record_changelog.record_identifier.should == @piping_class.record_changelog_identifier
		record_changelog.action.should == 'Created'
		record_changelog.field_name.should == nil
		record_changelog.old_value.should == nil
		record_changelog.new_value.should == nil
		record_changelog.modified_by.should == 'Adam'
	end
end

describe RecordChangelog, "When deleting records" do

    before(:each) do
    	Employee.stub!(:current_employee_name).and_return('Adam')
    end

	it "should record the deletion of records" do
    	RecordChangelog.enable_recording = false
    	@piping_class = PipingClass.generate(:class_code => "ABC")
    	RecordChangelog.enable_recording = true
    	@piping_class.destroy
		RecordChangelog.count.should == 1
		record_changelog = RecordChangelog.first
		record_changelog.record_type.should == @piping_class.class.to_s.titleize
		record_changelog.record_identifier.should == @piping_class.record_changelog_identifier
		record_changelog.action.should == 'Deleted'
		record_changelog.field_name.should == nil
		record_changelog.old_value.should == nil
		record_changelog.new_value.should == nil
		record_changelog.modified_by.should == 'Adam'
	end
end
