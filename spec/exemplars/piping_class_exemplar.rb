# == Schema Information
# Schema version: 121
#
# Table name: piping_classes
#
#  id                     :integer(11)   not null, primary key
#  archived               :boolean(1)
#  class_code             :string(255)
#  comments               :text
#  corrosion_allow        :string(255)
#  created_at             :datetime
#  flange_rating          :string(255)
#  gasket_bolting         :string(255)
#  gasket_material        :string(255)
#  instr_spec             :string(255)
#  maintenance_note       :text
#  max_pressure           :string(255)
#  max_temp               :string(255)
#  piping_material        :string(255)
#  service                :string(255)
#  small_fitting          :string(255)
#  special_note           :text
#  updated_at             :datetime
#  valve_body_material    :string(255)
#  valve_trim             :string(255)
#  consequence_of_failure :string(255)
#

class PipingClass < ActiveRecord::Base
	generator_for :class_code, :start => "AAA" do |prev|
		prev.succ
	end
end

