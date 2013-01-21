require File.dirname(__FILE__) + '/../spec_helper'

# == Schema Information
# Schema version: 20090730175917
#
# Table name: piping_classes
#
#  id                     :integer(4)    not null, primary key
#  archived               :boolean(1)    
#  class_code             :string(255)   
#  comments               :text          
#  corrosion_allow        :string(255)   
#  created_at             :datetime      
#  flange_rating          :string(255)   
#  gasket_bolting         :string(255)   
#  gasket_material        :string(255)   
#  instr_spec             :string(255)   
#  maintenance_note       :text          
#  max_pressure           :string(255)   
#  max_temp               :string(255)   
#  piping_material        :string(255)   
#  service                :text          
#  small_fitting          :string(255)   
#  special_note           :text          
#  updated_at             :datetime      
#  valve_body_material    :string(255)   
#  valve_trim             :string(255)   
#  consequence_of_failure :string(255)   
#


describe PipingClass, "When cloning a PipingClass" do

    before(:each) do
   		@piping_class = PipingClass.generate(:class_code => "ABC")

		3.times do |i|
			detail = PipingClassDetail.generate(:piping_class => @piping_class)
			detail.piping_notes << PipingNote.generate
		end
		
		@piping_class.save
    end

	it "should assign the new class_code to the cloned piping class" do
		@new_piping_class = @piping_class.clone_with_piping_class_details_and_piping_notes("CBA")
		@piping_class.class_code.should == "ABC"
		@new_piping_class.class_code.should == "CBA"
	end

	it "should not clone if the class_code already exists" do
		@new_piping_class = @piping_class.clone_with_piping_class_details_and_piping_notes(@piping_class.class_code)
		
		PipingClass.count.should == 1
		PipingClassDetail.count.should == 3
		PipingNote.count.should == 3
	end

	it "should clone all associated piping class details " do
		@new_piping_class = @piping_class.clone_with_piping_class_details_and_piping_notes("CBA")
		@piping_class.piping_class_details.size.should == 3
		@new_piping_class.piping_class_details.size.should == 3
		@new_piping_class.piping_class_details.each do |pcd|
			@piping_class.piping_class_details.should_not be_include(pcd)
		end
	end

	it "should maintain the PipingNote associations with the new PipingClassDetails" do
		@new_piping_class = @piping_class.clone_with_piping_class_details_and_piping_notes("CBA")
		old_notes = []
		@piping_class.piping_class_details.each do |pcd|
			pcd.piping_notes.size.should == 1
			pcd.piping_notes.each {|pn| old_notes << pn }
		end
		new_notes = []
		@new_piping_class.piping_class_details.each do |pcd|
			pcd.piping_notes.size.should == 1
			pcd.piping_notes.each {|pn| new_notes << pn }
		end
		new_notes.each do |nn|
			old_notes.should be_include(nn)
		end
	end
end

describe PipingClass, "Should record creation, modification, and deletion of records" do
    before(:each) do
    	Employee.stub!(:current_employee_name).and_return('Adam')
    end

	it "should record creation of record" do
		RecordChangelog.should_receive(:record_creation).once
    	@piping_class = PipingClass.generate(:class_code => "ABC")
	end

	it "should record creation of record" do
		RecordChangelog.should_receive(:record_deletion).once
		RecordChangelog.disable_recording {
	    	@piping_class = PipingClass.generate(:class_code => "ABC")
		}
		@piping_class.destroy
	end

	it "should set record_changelog_identifier to the class_code" do
		class_code = 'CBA'
		@piping_class = PipingClass.generate(:class_code => class_code)
		@piping_class.record_changelog_identifier.should == class_code
	end


	describe PipingClass, "When modifying attributes and field values" do

	    before(:each) do
	    	RecordChangelog.disable_recording {
		    	@piping_class = PipingClass.generate(:class_code => "ABC")
			}
	    end

		it "should record two changes before update" do
			@piping_class.class_code = "CBA"
			@piping_class.comments = "Some Comment"
			@piping_class.save
			RecordChangelog.count.should == 2
		end
		
	end

end
