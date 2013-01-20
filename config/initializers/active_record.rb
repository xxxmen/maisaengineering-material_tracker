# class ActiveRecord::Base
#   def method_missing_with_force_define_attribute_methods(method_id, *args, &block)
#     self.class.define_attribute_methods unless self.class.generated_methods?
#     method_missing_without_force_define_attribute_methods(method_id, *args, &block)
#   end
#   alias_method_chain :method_missing, :force_define_attribute_methods
  
#   def respond_to_with_force_define_attribute_methods?(method, include_private_methods = false)
#     self.class.define_attribute_methods unless self.class.generated_methods?
#     respond_to_without_force_define_attribute_methods?(method, include_private_methods)
#   end
#   alias_method_chain :respond_to?, :force_define_attribute_methods
# end