# == Schema Information
# Schema version: 20090730175917
#
# Table name: tracking_number_types
#
#  id           :integer(4)    not null, primary key
#  name         :string(255)   
#  order_number :integer(4)    
#  created_at   :datetime      
#  updated_at   :datetime      
#  created_by   :integer(4)    
#  updated_by   :integer(4)    
#

class ReferenceNumberType < ActiveRecord::Base

  	##############################################################################
  	# ATTRIBUTES
  	##############################################################################
	cattr_accessor :skip_default_callback
	@@skip_default_callback = false

  	##############################################################################
  	# VALIDATIONS	
  	##############################################################################
  
	validates_presence_of :name, :order_number
	validates_numericality_of :order_number
	
	##############################################################################
	# CALLBACKS
  	##############################################################################

	before_save :reset_defaults, :current_employee_b_save
  before_create :current_employee_b_create
	
	  	
	def current_employee_b_create
		self.created_by = Employee.current_employee_id
	end
	
	def current_employee_b_save
		self.updated_by = Employee.current_employee_id
	end
	
	def reset_defaults
		unless @@skip_default_callback
			if self.default == true || self.default == '1'
				defaults = self.class.find(:all, :conditions => {:default => true})
				defaults.each do |record|
					record.default = false
					record.skip_default_callback = true
					record.save
				end
			end
		end
	end
	
  	##############################################################################
  	# CLASS METHODS
  	##############################################################################
  	
  	def self.get_default_type
		the_default = self.find(:first, :conditions => {:default => true})
		unless the_default.present?
			the_default = self.find(:first, :order => 'name ASC')
		end
		the_default.present? ? the_default.name : ''		
	end

  	def self.get_list
		self.find(:all, :order => 'order_number ASC')  		
	end
	
	def self.get_list_for_combo
		types = self.get_list
		types.map { |t| t.name }
	end
  
  	##############################################################################
  	# INSTANCE METHODS
  	##############################################################################
  
  
end
