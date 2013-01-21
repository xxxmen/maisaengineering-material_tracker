class PipingComponent < ActiveRecord::Base
	generator_for :piping_component, :start => "PipingComponent001" do |prev|
		prev.succ
	end
end
