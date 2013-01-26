# == Schema Information
# Schema version: 20090730175917
#
# Table name: attachings
#
#  id              :integer(4)    not null, primary key
#  attachable_id   :integer(4)    
#  piping_reference_id        :integer(4)    
#  attachable_type :string(255)   
#  created_at      :datetime      
#  updated_at      :datetime      
#

class PipingReferenceAttaching < ActiveRecord::Base
  	belongs_to :piping_reference, :counter_cache => :attachings_count
  	belongs_to :attachable, :polymorphic => true
  
  	validates_presence_of :attachable_id, :attachable_type, :piping_reference_id
  	validates_uniqueness_of :piping_reference_id, 
  		:scope => [:attachable_type, :attachable_id],
  		:message => "has already been attached"

    after_destroy :piping_reference_a_destroy
  	def piping_reference_a_destroy
    	if self.piping_reference.attachings.count == 0 && self.piping_reference.show_public_link != true
    		self.piping_reference.destroy
   		end
  	end
end
