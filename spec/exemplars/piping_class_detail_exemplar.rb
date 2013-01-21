# == Schema Information
# Schema version: 121
#
# Table name: piping_class_details
#
#  id                  :integer(11)   not null, primary key
#  created_at          :datetime
#  description         :string(255)
#  piping_class_id     :integer(10)
#  piping_component_id :integer(10)
#  section_no          :integer(10)
#  size_desc           :string(255)
#  updated_at          :datetime
#  valve_id            :integer(10)
#

class PipingClassDetail < ActiveRecord::Base
    generator_for :description, :start => 'Description A' do |prev|
        prev.succ
    end

    generator_for :size_desc, :start => '1' do |prev|
        prev.succ
    end
end

