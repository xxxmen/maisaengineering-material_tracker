require File.dirname(__FILE__) + "/../lib/states_for"

class String
  def pluralize
    return self + "s"
  end
end

class User
  attr_accessor :role, :job
  extend StatesFor
  
  states_for :role => ["Client", "Employee", "Admin"],
             :job => ["Programmer", "Designer", "Project Manager", "Quality Assurance"]

  def self.redefine_options_for
    self.class.send(:define_method, 'options_for_role') do
      return [["Admin", User::ADMIN], ["Employee", User::EMPLOYEE], ["Client", User::CLIENT]]
    end
  end
  
end

describe "The states_for plugin" do
  it "should declare the constants 'CLIENT', 'EMPLOYEE', and 'ADMIN'" do
    User::CLIENT.should == 0
    User::EMPLOYEE.should == 1
    User::ADMIN.should == 2
  end
  
  it "should declare the constants 'PROGRAMMER', 'DESIGNER', 'PROJECT_MANAGER', and 'QUALITY_ASSURANCE'" do
    User::PROGRAMMER.should == 0
    User::DESIGNER.should == 1
    User::PROJECT_MANAGER.should == 2
    User::QUALITY_ASSURANCE.should == 3
  end
  
  it "should define the method 'roles' and 'jobs'" do
    User.roles.should == [0, 1, 2]
    User.jobs.should == [0, 1, 2, 3]
  end
  
  it "should define the methods 'client?', 'employee?', 'admin?', 'programmer?', 'designer?', 'project_manager?', 'quality_assurance?'" do
    hugh = User.new
    hugh.role = User::CLIENT
    hugh.job = User::PROGRAMMER
    
    hugh.should be_client
    hugh.should_not be_employee
    hugh.should_not be_admin
    
    hugh.should be_programmer # of course!
    hugh.should_not be_designer
    hugh.should_not be_project_manager
    hugh.should_not be_quality_assurance
  end
  
  it "should define the method 'options_for_role'" do
    User.options_for_role.should == [
      ["Client", User::CLIENT],
      ["Employee", User::EMPLOYEE],
      ["Admin", User::ADMIN]
    ]
  end
  
  it "should return the role for 'state_for_role'" do
    hugh = User.new
    hugh.role = User::CLIENT
    hugh.state_for_role.should == "Client"
    
    hugh.role = User::EMPLOYEE
    hugh.state_for_role.should == "Employee"
    
    User.redefine_options_for
    hugh.role = User::CLIENT
    hugh.state_for_role.should == "Client"
    
    hugh.role = User::ADMIN
    hugh.state_for_role.should == "Admin"
  end
  
  # TODO: should there be validations so that the state MUST be within 0..number of states
  it "should allow validation of role and job" do
    User.should respond_to(:validates_inclusion_of_role)
    User.should respond_to(:validates_inclusion_of_job)
  end
  
  it "should validate inclusion of role within 0..2" do
    User.should_receive(:validates_inclusion_of).with(:role, :in => 0..2)
    User.validates_inclusion_of_role
  end
  
  it "should validate inclusion of job within 0..3" do
    User.should_receive(:validates_inclusion_of).with(:job, :in => 0..3)
    User.validates_inclusion_of_job
  end
  
  it "should pass validation options to validates_inclusion_of" do
    User.should_receive(:validates_inclusion_of).with(:role, :in => 0..2, :allow_nil => true, :message => "should be within 0..2")
    User.validates_inclusion_of_role :allow_nil => true, :message => "should be within 0..2"
  end
  
  it "should use the new 'options_for_role' method" do
    User.redefine_options_for
    User.options_for_role.should == [["Admin", User::ADMIN], ["Employee", User::EMPLOYEE], ["Client", User::CLIENT]]
  end
end