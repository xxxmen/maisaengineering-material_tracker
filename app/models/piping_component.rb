# == Schema Information
# Schema version: 20090730175917
#
# Table name: piping_components
#
#  id               :integer(4)    not null, primary key
#  created_at       :datetime
#  display_seq_no   :integer(4)
#  piping_component :string(255)
#  updated_at       :datetime
#  parent_id        :integer(4)
#

class PipingComponent < ActiveRecord::Base

	############################################################################
	# CONSTANTS
	############################################################################

	SEXT_INCLUDE = [:user_notes, :subcomponents]

	############################################################################
	# ASSOCIATIONS
	############################################################################

  	has_many :piping_class_details
  	has_many :piping_classes, :through => :piping_class_details, :uniq => true

  	has_many :user_notes, :as => :table, :dependent => :destroy

  	has_many :subcomponents,
  		:foreign_key => 'parent_id',
  		:class_name => 'PipingComponent'

  	belongs_to :parent_component,
  		:foreign_key => 'parent_id',
  		:class_name => 'PipingComponent'

    has_many :record_changelogs, :as => :record

	############################################################################
	# VALIDATIONS
  	############################################################################
  	validates_presence_of :piping_component

	############################################################################
	# CALLBACKS
  	############################################################################

    # Logs any field changes (not creates or deletes, though...)
  	before_update { |record| RecordChangelog.record_changes(record) }
  	after_create { |record| RecordChangelog.record_creation(record) }
	before_destroy :check_for_associated_piping_class_details
	after_destroy { |record| RecordChangelog.record_deletion(record) }

    ############################################################################
  	# INSTANCE METHODS
  	############################################################################

  def has_children
    (self.subcomponents.count > 0)
  end
	# Raises an error if there are still associated PipingClassDetails.
	def check_for_associated_piping_class_details
		if self.piping_class_details.count > 0
			raise ActiveRecord::ActiveRecordError.new("Cannot delete this Component, there are still Piping Class Details associated.")
		elsif self.subcomponents.count > 0
			raise ActiveRecord::ActiveRecordError.new("Cannot delete this Component, there are still Subcomponents associated.")
		end
	end

	# For use by RecordChangelog
	def record_changelog_identifier
		self.piping_component
	end

	  #If the parent is a child of anything else, return false
	def validate
		if self.parent_component
	  		if self.parent_component.parent_component
	  			errors.add(:parent_id, "Parent Component must not have its own Parent.")
	  		end
	  	end
	  	return true
	end


	def sext_data(options = {})
	  	json = super(options)
	  	json[:subcomponents] = []
	  	self.subcomponents.each do |subcomp|
	  		json[:subcomponents] << subcomp
	  	end
      json[:has_children] = self.has_children
  		json[:user_note_data] = get_user_note_data

	  	return json
	end

	# Returns a string of concatenated Piping Classes that this Piping Component
	# is used in.
	def get_related_piping_classes
		details = PipingClassDetail.find(:all,
			:select => 'DISTINCT piping_classes.class_code',
			:joins => [:piping_class],
			:conditions => ['piping_class_details.piping_component_id = ?', self.id],
			:order => 'piping_classes.class_code ASC'
		)
		details.map {|d| d.class_code }.join(', ')
	end
end
