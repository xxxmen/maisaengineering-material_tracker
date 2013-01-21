require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def mock_piping_reference(&block)
	@piping_reference = mock(PipingReference)
	yield @piping_reference
	PipingReference.stub!(:new).and_return(@piping_reference)
end

describe PipingReferenceAttachingsController do

	before(:each) do
		controller.stub!(:is_popv_admin).and_return(true)
	end

  	it "should use PipingReferencesController" do
    	controller.should be_an_instance_of(PipingReferenceAttachingsController)
  	end

	describe "/piping_reference_attachings/create_with_piping_reference" do
	
		it "should return success if PipingReference was created successfully" do
			mock_piping_reference {|piping_reference| piping_reference.should_receive(:save_with_attaching).and_return(true) }
			post :create_with_piping_reference
			response.body.should match(/\"success\": true/)
		end
		
		
		it "should return success" do
			mock_piping_reference do |piping_reference| 
				piping_reference.should_receive(:save_with_attaching).and_return(false)
				errors = mock("errors", :each => {})
				piping_reference.should_receive(:errors).and_return(errors)
			end
			post :create_with_piping_reference
			response.body.should match(/\"success\": false/)
			response.body.should match(/\"errors\":/)
		end		
	end
end

