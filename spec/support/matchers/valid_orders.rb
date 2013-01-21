# Old Rails 1.2.3 Rspec Matcher Code:

#matcher :be_valid do |klass, order|
#  messages = []
#  order.valid?
#  order.errors.each_full { |msg| messages << "* " + msg }
#  
#  klass.failure = "expected order to be valid, but has errors:\n" + messages.join("\n")
#  klass.negative = "expected order to not be valid, but has no errors"
#  
#  order.valid?
#end

#matcher :be_invalid do |errors, order|
#  !order.valid?
#end


# Latest Rails (2.3.2) with Rspec (1.2.6) Matcher Code:
Spec::Matchers.define :be_valid do 
  match do |order|
  	order.valid?
  end
  
  failure_message_for_should do |actual_order|
  	messages = get_error_messages(actual_order)
  	"expected order to be valid, but has errors:\n" + messages
  end
  
  failure_message_for_should_not do |actual_order|
    "expected order to not be valid, but has no errors"
  end
  
  def get_error_messages(invalid_order)
    messages = []
    invalid_order.valid?
    invalid_order.errors.each_full { |msg| messages << "* " + msg }
    messages.join("\n")
  end
	
  description do
    "be a valid Order"
  end
end

Spec::Matchers.define :be_invalid do 
  match do |order|
  	!order.valid?
  end  
  
  failure_message_for_should do |order|
  	"expected order to be invalid, but has no errors"
  end
  
  failure_message_for_should_not do |invalid_order|
  	messages = get_error_messages(invalid_order)
    "expected order to be valid, but has errors:\n" + messages
  end
  
  def get_error_messages(invalid_order)
    messages = []
    invalid_order.valid?
    invalid_order.errors.each_full { |msg| messages << "* " + msg }
    messages.join("\n")
  end
	
  description do
    "be a invalid Order"
  end
end

