require File.dirname(__FILE__) + "/../spec_helper.rb"

describe Unit do  
    it "should be invalid with a description that's already taken" do
        peep = Unit.create(:description => "peep")
        peep2 = Unit.create(:description => "peep")
        
        peep.should be_valid
        peep2.should have(1).error_on(:description)
    end
  
    it "should match only number strings" do
        ("12345" =~ /\d/).should == 0
    end
end
