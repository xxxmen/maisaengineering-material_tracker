# == Schema Information
# Schema version: 20090730175917
#
# Table name: quote_items
#
#  id                     :integer(4)    not null, primary key
#  requested_line_item_id :integer(4)    
#  item_no                :integer(4)    
#  quote_id               :integer(4)    
#  quantity               :integer(4)    
#  notes                  :text          
#  created_at             :datetime      
#  updated_at             :datetime      
#  price                  :float         
#  date_available         :date          
#  unit_of_measure        :string(255)   
#  vendor_part_number     :string(255)   
#

class QuoteItem < ActiveRecord::Base
	
	############################################################################
  	# ASSOCIATIONS
  
  	belongs_to :requested_line_item
  	belongs_to :quote  
  
    ############################################################################
  	# ATTRIBUTES
  
  	attr_writer :ext_price
  
  	############################################################################
  	# VALIDATIONS
  	
  	validates_presence_of :quote_id, :item_no
  
  	############################################################################
  	# INSTANCE METHODS
  
  	def initialize(*args)
	    super
	    self.quantity ||= 0
	    self.date_available ||= Date.today
	    self.price ||= 0.00
	end
  
  	def ext_price
    	return self.quantity * self.price
  	end
  
	def differs_from_requested?
		if self.requested_line_item 
		 	self.requested_line_item.material_description != self.notes ||
		 	self.requested_line_item.quantity != self.quantity ||
		 	self.requested_line_item.unit_of_measure != self.unit_of_measure  	 	
		else
		 	false
	 	end
	end
end
