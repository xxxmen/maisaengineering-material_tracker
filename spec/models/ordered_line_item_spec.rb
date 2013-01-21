require File.dirname(__FILE__) + '/../spec_helper'

def set_qtys(ordered, received = nil, issued = nil)
    return {:quantity_ordered => ordered, :quantity_received => received, :issued_quantity => issued}
end

describe OrderedLineItem, "when updating a line item's attributes" do
    before(:each) do
    	PoStatus.stub!(:fully_received_id).and_return(1)
    	PoStatus.stub!(:partially_received_id).and_return(2)
    	@order = Order.generate
        @item = OrderedLineItem.create({
            :po_id => @order.id,
            :description => 'New Item',
            :quantity_ordered => 1
        })
    end
    
    
    it "should save if given just a quantity" do
        lambda { 
          @item.update_attributes_with_splitting().should == true
        }.should change(OrderedLineItem, :count).by(0)        
    end

    it "should fail if given a quantity and issued quantity with nothing received" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(5,nil,3)).should == false
        }.should change(OrderedLineItem, :count).by(0)        
    end

    it "should split the line item if given a quantity and a lesser received quantity with nothing issued " do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(5,2)).should == true
        }.should change(OrderedLineItem, :count).by(1)        
    end

    it "should save the line item if given a quantity and a greatae received quantity with nothing issued " do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(5,7)).should == true
        }.should change(OrderedLineItem, :count).by(0)        
    end
    
    it "should save the line item if given a quantity and an equal received quantity with nothing issued " do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(5,5)).should == true
        }.should change(OrderedLineItem, :count).by(0)        
    end

    it "should split the line item into 2 if given a quantity and lesser but duplicate received quantity and issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(5,2,2)).should == true
        }.should change(OrderedLineItem, :count).by(1)        
    end

    it "should fail if given a large quantity, small received quantity, and medium issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(5,2,3)).should == false
        }.should change(OrderedLineItem, :count).by(0)        
    end


    it "should split into 3 items if given a large quantity, a medium received quantity, and a small issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(5,3,2)).should == true
        }.should change(OrderedLineItem, :count).by(2)        
    end

    it "should split into 3 items if given a large quantity, a large received quantity, and a lesser issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(5,5,2)).should == true
        }.should change(OrderedLineItem, :count).by(1)        
    end

    it "should save if given the same quantity, received quantity, and issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(5,5,5)).should == true
        }.should change(OrderedLineItem, :count).by(0)        
    end

    it "should save if given the a medium quantity, a large received quantity, and a large issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(3,5,5)).should == true
        }.should change(OrderedLineItem, :count).by(0)        
    end

    it "should fail if given the a small quantity, a medium received quantity, and a large issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(2,3,5)).should == false
        }.should change(OrderedLineItem, :count).by(0)        
    end

    it "should fail if given the a small quantity, a large received quantity, and a medium issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(2,5,3)).should == true
        }.should change(OrderedLineItem, :count).by(1)        
    end

    it "should fail if given the a small quantity, a large received quantity, and a small issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(2,5,2)).should == true
        }.should change(OrderedLineItem, :count).by(1)        
    end

    it "should fail if given the a medium quantity, a large received quantity, and a small issued quantity" do
        lambda { 
          @item.update_attributes_with_splitting(set_qtys(3,5,2)).should == true
        }.should change(OrderedLineItem, :count).by(1)        
    end
end

describe OrderedLineItem, "when checking if an item is issueable" do
    before(:each) do
        @item = OrderedLineItem.new({
            :po_id => 1,
            :description => 'New Item',
            :quantity_ordered => 10
        })
    end
    
    it "should not be issuable" do
          @item.issueable?.should == false
    end

    it "should be issuable" do
        @item.quantity_received = 10
        @item.date_received = Date.today
        @item.issueable?.should == true
    end
    
    it "should not be issuable" do
        @item.date_received = Date.today
        @item.issueable?.should == false
    end

    it "should be issuable" do
        @item.quantity_received = @item.quantity_ordered.to_i + 1
        @item.date_received = Date.today
        @item.issueable?.should == true
    end
    
    it "should not be issuable" do
        @item.quantity_received = 3
        @item.date_received = Date.today
        @item.issueable?.should == false
    end
    
    it "should not be issuable" do
        @item.quantity_received = @item.quantity_ordered
        @item.date_received = Date.today
        @item.issued_date = Date.today
        @item.issueable?.should == false
    end
    
    it "should not be issuable" do
        @item.quantity_received = @item.quantity_ordered
        @item.date_received = Date.today
        @item.issued_quantity = 3
        @item.issueable?.should == false
    end
    
    
end
