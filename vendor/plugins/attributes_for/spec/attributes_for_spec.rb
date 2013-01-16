require File.dirname(__FILE__) + "/../lib/attributes_for"
require File.dirname(__FILE__) + "/spec_helper"

describe "Using AttributesFor.valid" do
  include AttributesFor
  
  before(:each) do
    AttributesFor.valid :user, :login => "hugh", :password => "bien"    
  end
  
  it "should define valid_user, create_user, and new_user methods" do
    self.should respond_to(:valid_user)
    self.should respond_to(:create_user)
    self.should respond_to(:new_user)
  end
  
  it "should return a hash of attributes for valid_user" do
    valid_user.should == { :login => "hugh", :password => "bien" }
  end
  
  it "should return a new user with valid attributes for new_user" do
    user = new_user
    user.attributes.should == { :login => "hugh", :password => "bien" }
    user.should be_new_record
  end
  
  it "should return a created user with valid attributes for create_user" do
    user = create_user
    user.attributes.should == { :login => "hugh", :password => "bien" }
    user.should_not be_new_record
  end
  
  it "should override the default attributes hash" do
    valid_user(:password => nil).should == { :login => "hugh", :password => nil }
    new_user(:login => "bien").attributes.should == { :login => "bien", :password => "bien" }
    create_user(:login => nil, :password => "blank").attributes.should == { :login => nil, :password => "blank" }
  end
end

describe "Using AttributesFor.invalid" do
  include AttributesFor
  
  before(:each) do
    AttributesFor.invalid :user, :login => "", :password => 1
  end
  
  it "should define invalid_user, create_invalid_user, and new_invalid_user" do
    self.should respond_to(:invalid_user)
    self.should respond_to(:create_invalid_user)
    self.should respond_to(:new_invalid_user)
  end
end