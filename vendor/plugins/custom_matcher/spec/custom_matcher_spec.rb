require File.dirname(__FILE__) + "/../lib/custom_matcher"
require File.dirname(__FILE__) + "/spec_helper"

matcher :validate do |messages, user|
  user.valid?
end

matcher :use_login_longer_than do |messages, user, login_length|
  messages.failure = "expected user '#{user.login}' to use a login longer than #{login_length.to_s}"
  messages.negative = "expected user '#{user.login}' to use a login no longer than #{login_length.to_s}"
  
  user.login.length > login_length
end

matcher :use_login_and_password do |messages, user, login, password|
  user.login == login && user.password == password
end

matcher :use_login => "UserSpecHelper" do |messages, user|
  messages.failure = "expected user '#{user.login}' to use a login but he does not"
  messages.negative = "expected user '#{user.login}' to not use a login but he does"
  
  user.login != nil
end

matcher :use_password => "UserSpecHelper" do |messages, user|
  messages.failure = "expected user '#{user.login}' to use a password but he does not"
  messages.negative = "expected user '#{user.login}' to not use a password but he does"
  
  user.password != nil
end

describe CustomMatcher, "for 'validate' matcher" do
  include CustomMatcher
    
  it "should create a new method" do
    self.should respond_to(:validate)
  end
  
  it "should use the default error messages" do
    user = User.new(:valid => true)
    validator = CustomMatcher::Validate.new
    validator.matches?(user)
    
    validator.failure_message.should == "expected #{user} to validate; but it didn't"
    validator.negative_failure_message.should == "expected #{user} not to validate; but it did"
  end
  
  it "should validate a valid user" do
    user = User.new(:valid => true)
    user.should validate
    
    user.valid = false
    user.should_not validate
  end
  
  it "should not pollute the global namespace" do
    lambda { Validate }.should raise_error(NameError)
    lambda { CustomMatcher::Validate }.should_not raise_error(NameError)
  end
  
  it "should define methods :new, :failure_message, :negative_failure_message, and :matches?" do
    val = CustomMatcher::Validate.new
    val.should respond_to(:failure_message)
    val.should respond_to(:negative_failure_message)
    val.should respond_to(:matches?)
  end
  
  it "should initialize a new Validate for the 'validate' method" do
    validate.should be_kind_of(CustomMatcher::Validate)
  end
  
  it "should be able to take in random numbers of arguments" do
    user = User.new(:valid => true)
    
    # All arguments are passed directly to the 'matcher' method
    # matcher :method_name do |messages, user, arg1, arg2, arg3 ... |
    user.should validate
    user.should validate(:asdf)
    user.should validate(:asdf, :qwerty)
  end
end

describe CustomMatcher, "for 'use_login_longer_than' matcher" do
  include CustomMatcher
  
  it "should define the method 'use_login_longer_than'" do
    user = User.new(:valid => true)
    user.login = "hugh"
    user.should use_login_longer_than(3)
    user.should_not use_login_longer_than(4)
  end  
end

describe CustomMatcher, "for 'use_login_and_password' matcher" do
  include CustomMatcher
  it "should use the default messages" do
    user = User.new(:valid => true)
    
    default = CustomMatcher::UseLoginAndPassword.new("login", "password")
    default.matches?(user)
    
    default.failure_message.should == "expected #{user} to use_login_and_password login, password; but it didn't"
    default.negative_failure_message.should == "expected #{user} not to use_login_and_password login, password; but it did"
  end
  
  it "should be okay for two args" do
    user = User.new(:valid => true)
    user.login = "hugh"
    user.password = "hugh"
    
    user.should use_login_and_password("hugh", "hugh")
  end
end

describe CustomMatcher, "using a module for matchers 'use_login' and 'use_password'" do
  include CustomMatcher
  
  it "should not respond to use_login or use_password without being included" do
    self.should_not respond_to(:use_login)
    self.should_not respond_to(:use_password)
  end
  
  it "should define the UserSpecHelper constant" do
    Object.const_get("UserSpecHelper").should be_kind_of(Module)
  end
  
  it "should respond to both once the module is included" do
    extend UserSpecHelper
    self.should respond_to(:use_login)
  end
  
  it "should spec a user correctly" do
    extend UserSpecHelper
    user = User.new(:valid => true)
    user.login = nil; user.password = nil
    user.should_not use_login
    user.should_not use_password
    
    user.login = "hugh"; user.password = "asdf"
    user.should use_login
    user.should use_password
  end
end