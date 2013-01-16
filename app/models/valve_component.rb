# == Schema Information
# Schema version: 20090730175917
#
# Table name: valve_components
#
#  id              :integer(4)    not null, primary key
#  component_name  :string(255)   
#  created_at      :datetime      
#  display_seq_no  :integer(4)    
#  updated_at      :datetime      
#  order_numbering :integer(4)    
#

class ValveComponent < ActiveRecord::Base

    ############################################################################
    # CONSTANTS  
    ############################################################################
    
    SEXT_INCLUDE = [:user_notes]

    ############################################################################
    # ASSOCIATIONS
    ############################################################################

    has_many :valves_valve_components
    has_many :valves, :through => :valves_valve_components
    has_many :user_notes, :as => :table
    has_many :record_changelogs, :as => :record
    
	############################################################################
	# CALLBACKS
	############################################################################
	  
    # Logs any field changes (not creates or deletes, though...)
  	before_update { |record| RecordChangelog.record_changes(record) }
  	after_create { |record| RecordChangelog.record_creation(record) }
  	after_destroy { |record| RecordChangelog.record_deletion(record) }

    ############################################################################
    # VALIDATIONS
    ############################################################################

	validates_presence_of :component_name
	
    ############################################################################
  	# INSTANCE METHODS
  	############################################################################

	# For use by RecordChangelog
	def record_changelog_identifier
		self.component_name
	end	
	
	def sext_data(options = {})
		json = super(options)
		
	  	json[:user_note_data] = get_user_note_data
	  	
	  	return json
	end
end
