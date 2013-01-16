class User
  attr_accessor :attributes, :new_record, :valid, :login, :password
  
  def initialize(attrs)
    @attributes = attrs
    @new_record = true
    @valid = true
  end
  
  def self.create(attrs)
    user = User.new(attrs)
    user.new_record = false
    return user
  end
  
  def new_record?
    @new_record
  end
  
  def valid?
    @valid
  end
end

class String
  def camelize
    self.split("_").map { |s| s.capitalize }.join("")
  end
end
