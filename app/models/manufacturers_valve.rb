# == Schema Information
# Schema version: 20090730175917
#
# Table name: manufacturers_valves
#
#  id              :integer(4)    not null, primary key
#  manufacturer_id :integer(4)
#  valve_id        :integer(4)
#  figure_no       :text
#

class ManufacturersValve < ActiveRecord::Base
	belongs_to :manufacturer
	belongs_to :valve


	after_save :set_valve_updated_at

	def set_valve_updated_at
		v = self.valve
		v.updated_at = Time.now
		v.save!
	end
end
