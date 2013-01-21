module CustomMatcher
  def self.matcher(method_name)
    # Extract the method name and module name
    if method_name.is_a?(Hash)
      module_name = method_name.values[0]
      method_name = method_name.keys[0]
    else
      module_name = "CustomMatcher"
    end
    
    # get the module if it exists, if it doesn't then create it
    mod = Object.const_defined?(module_name) ? Object.const_get(module_name) : Object.const_set(module_name, Module.new)
    
    class_name = method_name.to_s.camelize
    # get the class if it exists, if it doesn't then create it
    klass = mod.const_defined?(class_name) ? mod.const_get(class_name) : mod.const_set(class_name, Class.new)
  
    klass.instance_eval do 
      attr_accessor :failure_message, :negative_failure_message
      alias_method :failure=, :failure_message=
      alias_method :negative=, :negative_failure_message=
  
      define_method(:initialize) do |*args|
        @expected = args
      end
  
      define_method(:matches?) do |target|
        expected = @expected.empty? ? "" : " " + @expected.join(', ')
        @failure_message = "expected #{target} to #{method_name}#{expected}; but it didn't"
        @negative_failure_message = "expected #{target} not to #{method_name}#{expected}; but it did"
        
        yield(self, target, *@expected)
      end
    end

    mod.send(:define_method, method_name) do |*args|
      klass.new(*args)
    end
  end  
end

# order.should validate
# order.should have_error(:username => "can't be blank")
# order.should have_errors(:username => "can't be blank", :password => "can't be blank")
def matcher(method_name)
  CustomMatcher.matcher(method_name) do |*args|
    yield *args
  end
end