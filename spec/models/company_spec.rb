require File.dirname(__FILE__) + "/../spec_helper"

describe Company do
  include CustomMatcher
  
  it "should have many employees" do
    apple = Company.new
    apple.should respond_to(:employees)
    apple.employees.build(valid_employee)
    apple.employees.size.should == 1
  end
  
  it "should be invalid without a name" do
    apple = Company.new(:name => "")
    apple.should have(1).error_on(:name)
  end
  
  it "should validate the uniqueness of a name" do
    apple = Company.new(:name => "apple computers")
    apple.save
    
    fruits = Company.new(:name => "apple computers")
    fruits.should_not be_valid # Apple should try to sue them now
  end
    
  it "should list all the companies for a form selector" do
    Company.destroy_all
    abc = create_company(:name => "ABC Industries")
    bee = create_company(:name => "BumbleBee Corp")
    dec = create_company(:name => "Decepticons Inc")
    
    Company.list_companies.should be_exactly([
      ["", nil],
      [abc.name, abc.id],
      [bee.name, bee.id],
      [dec.name, dec.id]
    ])
  end
end