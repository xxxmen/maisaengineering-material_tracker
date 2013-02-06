require File.dirname(__FILE__) + "/spec_helper"

User.all = [  User.new("hughd", "hugh", "secret"),
              User.new("", "cstrife", ""),
              User.new(nil, nil, "homer") ]

describe CsvFu do  
  before(:each) do
    @path = Rails.root + "/db/users.csv"
  end
  
  after(:each) do
    File.delete(@path) if File.exists?(@path)
  end
  
  it "should export all users to a CSV string" do
    User.to_csv.should == "login,name,password\nhughd,hugh,secret\n\"\",cstrife,\"\"\n,,homer\n"
  end
  
  it "should take a row and turn it into an array" do
    u = User.new("zid", "zidane", "password")
    u.to_row.should == ["zid", "zidane", "password"]
  end
  
  it "should treat regular objects in an Array with FasterCSV" do
    FasterCSV.should_receive(:generate_line).once
    [:one, :two, :three].to_csv
  end
  
  it "should write to users.csv with the csv string" do    
    # Should not exist until we dump the file
    File.exists?(@path).should == false
    User.dump_to_file
    File.exists?(@path).should == true
    
    # Should be the same CSV string
    IO.read(@path).should == User.to_csv    
  end
  
  it "should create users from a CSV string" do
    User.created.should == []
    CsvFu::create_from_csv(User, User.to_csv)
    User.created.size.should == 3
    User.created[0].login.should == "hughd"
    User.created[1].name.should == "cstrife"
    User.created[2].password.should == "homer"
  end
  
  it "should use generate_line on ActiveRecord objects" do
    # once for header, three times for content
    FasterCSV.should_receive(:generate_line).exactly(4).times
    User.find(:all).to_csv
  end
  
  it "should return an empty string for an empty array" do
    [].to_csv.should == ""
  end
end
