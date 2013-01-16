require File.dirname(__FILE__) + '/../spec_helper'

describe BomsController do

  	#Delete this example and add some real ones
  	it "should use BomsController" do
    	controller.should be_an_instance_of(BomsController)
  	end
end

describe BomsController, "When the BOM is exported as XML" do

	before(:each) do
		controller.stub!(:is_popv_admin).and_return(true)
		
		@bill = Bill.generate
		
		BillItem.generate(:description => "Bill Item 1", :bill => @bill)
		BillItem.generate(:description => "Bill Item 2", :bill => @bill)
		BillItem.generate(:description => "Bill Item 3", :bill => @bill)
		
		Bill.stub!(:find).and_return(@bill)
		#@bill.bill_items << BillItem.generate(:description => "Bill Item 2")
		#@bill.bill_items << BillItem.generate(:description => "Bill Item 3")
	end

	it "should divide up the bill items array into the appropriate size" do
		#Bill.stub!(:find_items_for_export).and_return(@bill.bill_items)
		#get :form_58001, :id => 1
		#assigns[:hello].should == 1 #.should == []
		
		
	end
end
