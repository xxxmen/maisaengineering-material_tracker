class Valve < ActiveRecord::Base
    generator_for :valve_code, :start => "V100" do |prev|
    	prev.succ    	
    end    
end

