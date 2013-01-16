require File.dirname(__FILE__) + '/../spec_helper'

describe Bill do
	# Keeps things from blowing up when no current_employee is assigned.
    before(:each) do
    	Employee.stub!(:current_employee).and_return(mock(:current_employee, :current_bom_id= => true, :save => true, :id => 1))
    	Event.stub!(:new).and_return(mock(:event, :save => true))
   	end
   	
   		
  	it "should call find_items_for_export" do
  		bill_id = 1
  		Bill.should_receive(:find_items_for_export).with(bill_id).and_return([])
  		Bill.find_items_for_xml_export(bill_id)
 	end
 	
 	it "should return 1 Bill Items array" do
  		items_array = (1..3).to_a
  		Bill.stub!(:find_items_for_export).and_return(items_array)
  		items = Bill.find_items_for_xml_export(0)
  		items.should == [[1,2,3]]  		
 	end
 	
 	it "should return 2 Bill Items arrays" do
  		items_array = (1..18).to_a
  		Bill.stub!(:find_items_for_export).and_return(items_array)
  		items = Bill.find_items_for_xml_export(0)
  		items.should == [(1..10).to_a, (11..18).to_a]  		
 	end
  
 	it "should return 4 Bill Items arrays" do
  		items_array = (0..39).to_a
  		Bill.stub!(:find_items_for_export).and_return(items_array)
  		items = Bill.find_items_for_xml_export(0)
  		items.should == [(0..9).to_a, (10..19).to_a, (20..29).to_a, (30..39).to_a]  		
 	end
  	
  	
  	describe "When superseding a Bill" do
  		
  		before(:each) do
  			@bill = Bill.generate({
  				:status => 'Draft',
  				:superseded => false
  			})
  			@bill.stub!(:after_create).and_return(true)
  			@bill.bill_items << BillItem.generate(:description => '1')
  			@bill.bill_items << BillItem.generate(:description => '2')
  			@bill.bill_items << BillItem.generate(:description => '3')
  			@bill.save
 		end
  		
  		it "should set the status to 'Superceded'" do
  			@bill.supersede
  			@bill.status.should == 'Superseded'
 		end	
  		
  		it "should set @superseded to true" do
  			@bill.supersede
  			@bill.superseded.should == true
 		end	

  		it "should return a newly created copy of Bill" do
  			@new_bill = @bill.supersede
  			@new_bill.should_not == @bill
 		end	

  		it "should tack on a number to the tracking number for first generation superseded bills" do
  			@bill.tracking = 'Tracking'
  			@new_bill = @bill.supersede
  			@new_bill.tracking.should == 'Tracking-1'
 		end	

  		it "should increment the endign digits in the tracking number for second or higher generation superseded bills" do
  			@bill.tracking = 'Tracking-9'
  			@new_bill = @bill.supersede
  			@new_bill.tracking.should == 'Tracking-10'
 		end	

 		it "should create new copies of all the old bill items" do
 			@new_bill = @bill.supersede
 			@new_bill.bill_items.count.should == @bill.bill_items.count
		end
 		
 		it "should create new bill items by copying the old ones" do
 			@new_bill = @bill.supersede
 			@bill.bill_items.each do |item|
 				new_item = @new_bill.bill_items.find_by_description(item.description)
 				(new_item == item).should == false 				
			end
		end
 	end
  	
  	describe "When creating a Material Request from a Bill" do
  		
  		before(:each) do
  			@bill = Bill.generate({
  				:status => 'Finalized',
  				:superseded => false
  			})
  			@bill.stub!(:after_create).and_return(true)
  			@bill.bill_items << BillItem.generate(:description => '1')
  			@bill.bill_items << BillItem.generate(:description => '2')
  			@bill.bill_items << BillItem.generate(:description => '3')
  			@bill.save
 		end
  		
  		it "should combine all 3 reference numbers and types" do
  			@bill.reference_number_1_type = 'Process'
  			@bill.reference_number_2_type = 'Ticket'
  			@bill.reference_number_3_type = 'MES'
  			
  			@bill.reference_number_1 = 'P1'
  			@bill.reference_number_2 = 'P2'
  			@bill.reference_number_3 = 'P3'
  			
  			@bill.create_material_request

  			@bill.material_request.reference_number_type.should == "Process/Ticket/MES"
  			@bill.material_request.reference_number.should == "P1/P2/P3"  			
 		end	

  		it "should use only 1 reference number and type" do
  			@bill.reference_number_1_type = nil
  			@bill.reference_number_2_type = 'ProC'
  			@bill.reference_number_3_type = nil
  			
  			@bill.reference_number_1 = nil
  			@bill.reference_number_2 = 'P2'
  			@bill.reference_number_3 = nil
  			
  			@bill.create_material_request

  			@bill.material_request.reference_number_type.should == "ProC"
  			@bill.material_request.reference_number.should == "P2"  			
 		end	

  		
 	end
end
