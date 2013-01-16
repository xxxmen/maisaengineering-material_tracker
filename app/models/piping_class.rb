# == Schema Information
# Schema version: 20090730175917
#
# Table name: piping_classes
#
#  id                     :integer(4)    not null, primary key
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
#  service                :text
#  small_fitting          :string(255)
#  special_note           :text
#  updated_at             :datetime
#  valve_body_material    :string(255)
#  valve_trim             :string(255)
#  consequence_of_failure :string(255)
#

class PipingClass < ActiveRecord::Base
  	############################################################################
  	# MIXINS
  	############################################################################

  	extend Listable::ModelHelper
  	# Added to include helper methods for dealing with polymorphic piping_references.
  	include PipingReferenceHelper

  	############################################################################
  	# CONSTANTS
  	############################################################################

  	PERPAGE = 400
	PAGE_LIMIT = 400
  	SEARCH_COLS = ["class_code"]
  	SEXT_SEARCH_FIELDS = ["class_code"]
  	SEXT_INCLUDE = [:user_notes, :piping_references]

  	############################################################################
  	# ASSOCIATIONS
  	############################################################################

  	has_many :piping_class_details, :dependent => :destroy

  	has_many :piping_components,
  			 :through => :piping_class_details,
  			 :uniq => true,
  			 :order => "piping_component"

  	has_many :user_notes, :as => :table
    has_many :record_changelogs, :as => :record

    has_many :piping_reference_attachings, :as => :attachable, :dependent => :destroy
    has_many :piping_references, :through => :piping_reference_attachings
	#acts_as_polymorphic_paperclip

  	############################################################################
  	# VALIDATIONS
  	############################################################################

	validates_presence_of :class_code
	validates_uniqueness_of :class_code

  	############################################################################
  	# CALLBACKS
  	############################################################################

  	# Logs any field changes (not creates or deletes, though...)
  	before_update { |record| RecordChangelog.record_changes(record) }
  	after_create { |record| RecordChangelog.record_creation(record) }
  	after_destroy { |record| RecordChangelog.record_deletion(record) }


  	############################################################################
  	# INSTANCE METHODS
  	############################################################################

	def initialize(*args)
		super(*args)
		self.archived ||= false
	end

	# For use by RecordChangelog
	def record_changelog_identifier
		self.class_code
	end

	def piping_reference_identifier
		self.class_code
	end

	##
	#	Clones the piping class, including its associated PipingClassDetails
	# 	and PipingNotes. Does it all in a transaction block so it rolls back
	# 	all changes if validations fail. Turns off recording changes so that
	# 	the cloned piping class details don't show up. We do a customized
	#	#record_creation call, passing in 'Cloned' as the action so it
	#	is more understandable to the user when scanning through the
	#	revision history.
	#
  	def clone_with_piping_class_details_and_piping_notes(new_code)
  		RecordChangelog.enable_recording = false
  		# Need to initialize this variable since it doesn't carry across
  		# if created inside the transaction block.
  		@new_piping_class = nil
	    transaction do
		    @new_piping_class = self.clone
		    @new_piping_class.class_code = new_code
		    # Auto-archive new clones
		    @new_piping_class.archived = true
		    @new_piping_class.save!
		    # Clones each detail
		    self.piping_class_details.each do |detail|
			    detail.clone_with_piping_notes(@new_piping_class.id)
		    end
    	end
  		RecordChangelog.enable_recording = true
  		# Custom revision history record
    	RecordChangelog.record_creation(@new_piping_class, {
    		:action => 'Cloned',
    		:field_name => 'Piping Class',
    		:old_value => self.class_code,
    		:new_value => @new_piping_class.class_code
    	})
    	return @new_piping_class
   	rescue ActiveRecord::RecordInvalid
  	ensure
  		# Be sure to re-enable recording even if this fails.
  		RecordChangelog.enable_recording = true
  		return @new_piping_class
	end

  # Sets the archived variable to true and saves the piping class.
  def archive
    self.archived = true
    self.save
  end
  def unarchive
    self.archived = false
    self.save
  end

  def class_code_and_service
  	if(self.service.blank?)
  		return self.class_code
  	else
  		return self.class_code + ' - ' + self.service
  	end
  end

  def class_only(options = {})
  	json = {}
    json[:id] = self.id
  	json[:class_code] = self.class_code
  	return json
  end

  def class_data(options = {})
  	json = {}
    json[:id] = self.id
  	json[:class_code_and_service] = self.class_code_and_service
  	return json
  end


  def self.filter(params)
    #vendor = params[:vendor]
    #unit = params[:unit]
    #status = params[:status]
    #location = params[:location]
    #state = params[:state]
    #year = params[:year]

    string = "1 = 1"
    #string += " AND vendor_id = ?" if !vendor.blank?
    #string += " AND unit_id = ?" if !unit.blank?
    #string += " AND status_id = ?" if !status.blank?
    #string += " AND location = ?" if !location.blank?

    #if !state.blank?
    #  if state == "open"
    #    string += " AND closed != ? AND completed != ?"
    #  elsif state == "completed"
    #    string += " AND closed != ? AND completed = ?"
    #  else # closed
    #    string += " AND closed = ?"
    #  end
    #end

    #string += " AND turnaround_year = ?" if !year.blank?

    conditions = [string]
    #conditions.push(vendor) if !vendor.blank?
    #conditions.push(unit) if !unit.blank?
    #conditions.push(status) if !status.blank?
    #conditions.push(location) if !location.blank?
    #conditions.push(true) if !state.blank?
    #conditions.push(true) if !state.blank? && (state == "open" || state == "completed")
    #conditions.push(year) if !year.blank?

    self.with_scope(:find => { :conditions => conditions }) do
      yield
    end
  end

  def self.reset_all_orders
    classes = PipingClass.find(:all, :order => "class_code ASC")
    classes.each do |c|
      c.reset_details_order
    end

  end
  def reset_details_order
    RecordChangelog.enable_recording = false
    piping_class = self
    index = 0
    puts "Class: #{piping_class.class_code}"
    PipingClassDetail.find(:all,
      :include => [:piping_component => :parent_component],
      :order => " (CASE WHEN (piping_components.parent_id IS NULL) THEN (piping_components.piping_component) 
ELSE (parent_components_piping_components.piping_component) END), 

piping_components.piping_component ASC, piping_class_details.size_desc ASC",
      :conditions => {:piping_class_id => piping_class.id}).each do |detail|
      detail.order = index
      detail.save!

      index += 1
    end
    RecordChangelog.enable_recording = true
  end
  # Calls super to grab a hash of all the users attributes and values
  # Adds another hash for company and role for JSON purposes
  def sext_data(options = {})
  	json = super(options)

    if((!self.cross_reference_class_id.blank?) && PipingClass.exists?(self.cross_reference_class_id))
      json[:cross_reference_class_link_id] = [{'id' => self.cross_reference_class_id.to_s, 'class_code' => PipingClass.find(self.cross_reference_class_id).class_code}]
    else
      json[:cross_reference_class_link_id] = ''
    end
  	json[:user_note_data] = get_user_note_data
  	# Populates :references_data with an array of piping_reference attributes for
  	# listing the references of piping classes. Defined in PipingReferenceHelper module.
  	json[:references_data] = self.get_piping_references
    json[:valve_count] = PipingClassDetail.count(:conditions => ["piping_class_id = ? AND valves.id IS NOT NULL", self.id], :include => :valve)
  	return json
  end

end

