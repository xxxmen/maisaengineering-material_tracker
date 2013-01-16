require File.dirname(__FILE__) + '/../spec_helper'

describe RequestedLineItem do  
  before(:each) do
    @requested_line_item = RequestedLineItem.new(:notes => "description")
  end

  it "should be valid" do
    # @requested_line_item.should be_valid
  end
    
  it "should not save a line item if all fields are blank" do
    @requested_line_item = RequestedLineItem.new
    # @requested_line_item.should be_valid
    lambda { @requested_line_item.save }.should_not change(RequestedLineItem, :count)
  end
end
