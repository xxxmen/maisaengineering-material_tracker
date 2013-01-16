
class Unit < ActiveRecord::Base  
    generator_for :description, :start => 'Unit 1' do |prev|
        prev.succ
    end
end
