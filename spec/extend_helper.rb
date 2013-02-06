module SpecHelper
  def change_role(role)
    employee = Employee.find_by_login("francdl")
    employee.role = role
    employee.save!
    @controller.stub!(:current_employee).and_return(employee)
  end
  
  def kill_index
    `rm -rf #{Rails.root}/index/test`
  end
end

class Array
  def equal_to?(array)
    # if they have the same size and same elements ...
    size == array.size && all? { |e| array.include?(e) }
  end
  
  def exactly?(array)
    # If they have same size, same elements, in the same order
    return false unless size == array.size
    each_with_index do |e, i| 
      return false if array[i] != e
    end
    return true
  end
end


def json_decode(thing)
	ActiveSupport::JSON.decode(thing)
end
