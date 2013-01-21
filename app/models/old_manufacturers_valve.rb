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

class OldManufacturersValve < ActiveRecord::Base
	belongs_to :old_manufacturer, :class_name => 'Manufacturer', :foreign_key => 'manufacturer_id'
	belongs_to :valve
	
end
