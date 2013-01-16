class ValveComponent < ActiveRecord::Base
	generator_for :component_name, :start => "Valve Component 1" do |prev|
		prev.succ
	end
end
