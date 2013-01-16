# == Schema Information
# Schema version: 20090730175917
#
# Table name: manufacturers
#
#  id         :integer(4)    not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Manufacturer < ActiveRecord::Base

	############################################################################
	# CONSTANTS

	SEXT_INCLUDE = [:user_notes, :valves]#,:valve_components,:manufacturers]

	############################################################################
	# ASSOCIATIONS

	has_many :user_notes, :as => :table
	has_many :manufacturers_valves
  	has_many :valves, :through => :manufacturers_valves


	############################################################################
	# VALIDATIONS

	validates_presence_of :name
	validates_uniqueness_of :name

	############################################################################
	# INSTANCE METHODS

	def sext_data(options = {})
		if options[:all]
			json = {}
			json[:id] = self.id
			json[:name] = self.name
		else
		    json = super(options)

			json[:valves] = []

			self.manufacturers_valves.each do |mv|
				valve = mv.valve
				if valve
					json[:valves] << {
						:valve_code => valve.valve_code,
						:valve_note => valve.valve_note,
						:figure_no => mv.figure_no
					}
				end
			end

		  	json[:user_note_data] = get_user_note_data
		end

		return json
	end

end
