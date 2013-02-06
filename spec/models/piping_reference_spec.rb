require File.dirname(__FILE__) + '/../spec_helper'

module PipingReferenceSpecHelper
	
	def temp_file
		ActionController::TestUploadedFile.new("#{Rails.root}/spec/test_data/sample_piping_reference.txt", "text/text")
	end
	
  	def new_piping_reference(attrs = {})
    	PipingReference.spawn(attrs)
  	end

  	def new_piping_reference_file(attrs = {})
    	PipingReference.spawn({
    	  	:data => temp_file
    	}.merge(attrs))
  	end

  	def new_piping_reference_link(attrs = {})
  		@link = "http://some.website.com"
    	PipingReference.spawn({
    	  	:custom_link => @link
    	}.merge(attrs))
  	end
end

describe PipingReference do
  	include PipingReferenceSpecHelper
  
  	before(:each) do
 	end
 	
 	it "should define #sext_data" do
 		PipingReference.new.should respond_to(:sext_data)
	end
 	
	describe "When calling #sext_data to get an attribute hash" do
		before(:each) do
			@piping_reference = new_piping_reference
			@hash = @piping_reference.sext_data
		end
		
		it "should have the necessary keys" do
			@hash.should have_key('description')
		end		
	end 	
 	
	describe "When creating an PipingReference" do
		before(:each) do
			@piping_reference = new_piping_reference
		end
		
		it "should validate that a data_file_name or custom_link needs to be present, but not both" do
			@piping_reference.save
			@piping_reference.should have(1).error_on(:data)
			@piping_reference.should have(1).error_on(:custom_link)
		end

		it "should not validate custom_link if data exists" do
			@piping_reference.data = temp_file
			@piping_reference.save
			@piping_reference.should have(0).error_on(:data)
			@piping_reference.should have(0).error_on(:custom_link)
		end

		it "should not validate data if custom_link exists" do
			@piping_reference.custom_link = "http://some.website.com"
			@piping_reference.save
			@piping_reference.should have(0).error_on(:data)
			@piping_reference.should have(0).error_on(:custom_link)
		end
				
		it "should set the reference_type to File if data has an associated file" do
			@piping_reference.data = temp_file
			@piping_reference.save
			@piping_reference.reference_type.should == 'File'
		end
		
		it "should set the reference_type to Link if data has an associated file" do
			@piping_reference.custom_link = "http://some.website.com"
			@piping_reference.save
			@piping_reference.reference_type.should == 'Link'
		end
	end
 	
	describe "When creating an PipingReferenceFile" do
		before(:each) do
			@piping_reference = new_piping_reference_file
		end
		
		it "should use data_file_name as the description if description doesn't exist" do
			@piping_reference.save
			@piping_reference.description.should == "sample_piping_reference.txt"
		end
				
		it "should validate that description is present" do
			@piping_reference.data.clear
			@piping_reference.description = nil
			@piping_reference.save.should == false
			@piping_reference.should have(1).error_on(:description)			
		end
		
		it "should use the provided description, even if there is an attachment" do
			@piping_reference.description = "New PipingReference"
			@piping_reference.save
			@piping_reference.description.should == "New PipingReference"
		end

		it "should reference the filename" do
			@piping_reference.save
			@piping_reference.reference.should == "sample_piping_reference.txt"
		end

		
	end

	describe "When creating an PipingReferenceLink" do
		before(:each) do
			@piping_reference = new_piping_reference_link
		end
		
		it "should require a description if PipingReference is a link" do
			@piping_reference.save
			@piping_reference.should have(1).errors_on(:description)
		end
				
		it "should reference the filename" do
			@piping_reference.save
			@piping_reference.reference.should == @link
		end
	end
	
	describe "When saving an PipingReference" do		
		it "should validate only one reference_type is allowed" do
			@piping_reference = new_piping_reference_link
			@piping_reference.data = temp_file
			@piping_reference.save
			@piping_reference.should have(1).errors_on(:custom_link)
			@piping_reference.should have(1).errors_on(:data)
		end
	end
	
	describe "When creating an PipingReference with an PipingReferenceAttaching" do
		before(:each) do
			@attachable = PipingClass.generate
			@piping_reference = PipingReference.new
			@params = {
				:description => 'Some Description',
				:custom_link => 'http://some.website.com',
				:data => '',
				:attachable_type => @attachable.class.to_s,
				:attachable_id => @attachable.id
			}
		end
	
		it "should create a valid PipingReference and a valid PipingReferenceAttaching" do
			result = @piping_reference.save_with_attaching(@params)
			@piping_reference.errors.full_messages.should == []
			@piping_reference.new_record?.should == false
			result.should == true
		end

		it "should fail if creating a valid PipingReference and an invalid PipingReferenceAttaching" do
			@params[:attachable_type] = ''
			@params[:attachable_id] = ''
			result = @piping_reference.save_with_attaching(@params)
			
			@piping_reference.errors.on(:attachable_type).should == "can't be blank"
			@piping_reference.errors.on(:attachable_id).should == "can't be blank"
			lambda { @piping_reference.reload }.should raise_error(ActiveRecord::RecordNotFound)
			result.should == false
		end

		it "should fail if creating an invalid PipingReference and an invalid PipingReferenceAttaching" do
			@params = {}
			result = @piping_reference.save_with_attaching(@params)
			
			@piping_reference.errors.on(:description).should == "can't be blank"
			@piping_reference.new_record?.should == true
			result.should == false
		end
	end
end
