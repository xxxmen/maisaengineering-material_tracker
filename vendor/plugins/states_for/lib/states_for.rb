# == Usage ==
# The states_for class method takes an ActiveRecord column and turns it into a
# field that has many states (represented by an INTEGER).
# == Example ==
#     class User < ActiveRecord::BASE
#       # users table should have a 'role' column of type INTEGER
#       states_for :role => ["Client", "Employee", "Admin"]
#     end
#
# This adds a few methods and constants:
# * User::CLIENT    # => 0
# * User::EMPLOYEE  # => 1
# * User::ADMIN     # => 2
# * User.roles      # => [0, 1, 2]
# * User.validates_inclusion_of_role  # => role column must be within 0..2
# * User.options_for_role   # => [["Client", 0], ["Employee", 1], ["Admin", 2]]
# * user.state_for_role     # => "Client"
# * user.client?, user.employee?, user.admin?    # => returns true if user.role == User::CONSTANT
module StatesFor
  def states_for(state_attributes)
    state_attributes.each do |attribute, states|
      # defines the CONSTANTS for each state
      states.each_with_index do |constant, index|
        self.const_set(constant.to_s.gsub(/[^a-zA-Z1-9_]/, "_").upcase, index)
      end

      # defines Class.options_for_attribute class method
      self.class.send(:define_method, "options_for_" + attribute.to_s) do
        states.map do |state|
          [state.to_s, self.const_get(state.to_s.gsub(/[^a-zA-Z1-9_]/, "_").upcase)]
        end
      end

      # defines the Class.attributes method
      self.class.send(:define_method, attribute.to_s.pluralize) do
        states.map { |state| self.const_get(state.to_s.gsub(/[^a-zA-Z1-9_]/, "_").upcase) }
      end

      # defines the Class.validates_inclusion_of_attribute class method
      self.class.send(:define_method, "validates_inclusion_of_" + attribute.to_s) do |*opts|
        opts[0] ||= {}
        validates_inclusion_of attribute, opts[0].merge(:in => 0..(states.size - 1))
      end

      # defines the model.state_for_attribute method
      define_method("state_for_" + attribute.to_s) do
        begin
          return states[self.send(attribute)]
        rescue TypeError # occurs when nil
          return ""
        end
      end

      # defines the model.state? methods
      states.map do |state|
        define_method(state.to_s.gsub(/[^a-zA-Z1-9_]/, "_").downcase + "?") do
          self.send(attribute) == self.class.const_get(state.to_s.gsub(/[^a-zA-Z1-9_]/, "_").upcase)
        end
      end
    end
  end
end