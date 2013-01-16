# == Schema Information
# Schema version: 20090730175917
#
# Table name: valves
#
#  id                    :integer(4)    not null, primary key
#  created_at            :datetime
#  discontinued          :boolean(1)
#  manufacturers_remarks :string(255)
#  updated_at            :datetime
#  valve_code            :string(255)
#  valve_note            :text
#  archived              :boolean(1)
#

class Valve < ActiveRecord::Base

  	# Added to include helper methods for dealing with polymorphic piping_references.
  	include PipingReferenceHelper

	############################################################################
	# CONSTANTS

    #This should cover the others...
  	SEXT_INCLUDE = [:valve_components]
  #[:valve_components]#[:user_notes, :piping_references]#,:valve_components,:manufacturers]
    #PAGE_ORDER_MAPPING = {:valve_component_text_1 => 'valves_valve_components.component_text',
    #                 :valve_component_name_1 => 'valve_components.component_name'}

	############################################################################
	# ASSOCIATIONS

    has_many :piping_class_details
    has_many :user_notes, :as => :table
    has_many :old_manufacturers,:through => :old_manufacturers_valves ,
    							:select => "manufacturers.*, old_manufacturers_valves.figure_no as figure_no, old_manufacturers_valves.valve_id as valve_id, old_manufacturers_valves.id as manufacturers_valves_id"
  	has_many :manufacturers, :through => :manufacturers_valves ,
  								:select => "manufacturers.*, manufacturers_valves.figure_no as figure_no, manufacturers_valves.valve_id as valve_id, manufacturers_valves.id as manufacturers_valves_id"
  	has_many :old_manufacturers_valves
  	has_many :manufacturers_valves
  	has_many :valve_components,
  		:through => :valves_valve_components,
  		:select => "valve_components.*, valves_valve_components.component_text as component_text, valves_valve_components.valve_id as valve_id, valves_valve_components.id as valves_valve_component_id"
  	has_many :valves_valve_components, :include => 'valve_component'
  	has_many :record_changelogs, :as => :record

    has_many :piping_reference_attachings, :as => :attachable, :dependent => :destroy
    has_many :piping_references, :through => :piping_reference_attachings

	############################################################################
	# VALIDATIONS

  	validates_presence_of :valve_code
    validates_uniqueness_of :valve_code

  	############################################################################
  	#	CALLBACKS

  	# Logs any field changes (not creates or deletes, though...)
  	before_update { |record| RecordChangelog.record_changes(record) }
  	after_create { |record| RecordChangelog.record_creation(record) }
  	after_destroy { |record| RecordChangelog.record_deletion(record) }

    ############################################################################
  	# CLASS METHODS
  	############################################################################

    ############################################################################
  	# INSTANCE METHODS
  	############################################################################

	def get_valve_components
		json = []
		self.valve_components.find(:all, :order => 'valve_components.order_numbering ASC').each do |comp|
			json << {
				:component_name => comp.component_name,
				:component_text => comp.component_text,
				:valve_id => comp.valve_id,
				:valve_component_id => comp.id,
				:valves_valve_component_id => comp.valves_valve_component_id
			}
		end
		json
	end


	def get_manufacturers
		json = []
		self.manufacturers.find(:all, :order => 'manufacturers.name ASC').each do |manu|
			json << {
				:name => manu.name,
				:figure_no => manu.figure_no,
				:manufacturers_valves_id => manu.manufacturers_valves_id,
				:manufacturer_id => manu.id,
				:valve_id => manu.valve_id
			}
		end
		json
	end

	def get_old_manufacturers
		json = []
		self.old_manufacturers.find(:all, :order => 'manufacturers.name ASC').each do |manu|
			json << {
				:name => manu.name,
				:figure_no => manu.figure_no,
				:manufacturers_valves_id => manu.manufacturers_valves_id,
				:manufacturer_id => manu.id,
				:valve_id => manu.valve_id
			}
		end
		json
	end

	# For use by RecordChangelog
	def record_changelog_identifier
		self.valve_code
	end

  ##
  #  Clones the valve, including its valve components and manufacturers
  #   Does it all in a transaction block so it rolls back
  #   all changes if validations fail. Turns off recording changes so that
  #   the cloned valve components don't show up. We do a customized
  #  #record_creation call, passing in 'Cloned' as the action so it
  #  is more understandable to the user when scanning through the
  #  revision history.
  #
    def deep_clone(new_code)
      RecordChangelog.enable_recording = false
      # Need to initialize this variable since it doesn't carry across
      # if created inside the transaction block.

      logger.error "Before Clone"
      @new_valve = self.clone
      logger.error "After Clone"
      transaction do

        @new_valve.valve_code = new_code
        # Auto-archive new clones
        @new_valve.archived = true
        @new_valve.save!
        logger.error "After New Valve Save"
        # Clones each component
        self.valves_valve_components.each do |detail|
          new_detail = detail.clone
          new_detail.valve = @new_valve
          new_detail.save!
        end
        logger.error "After Valve Components Clone"
        # Clones each manufacturer link
        self.manufacturers_valves.each do |detail|
          new_detail = detail.clone
          new_detail.valve = @new_valve
          new_detail.save!
        end
        logger.error "After Manufacturers Clone"
        # Clones each superseded manufacturer link
        self.old_manufacturers_valves.each do |detail|
          new_detail = detail.clone
          new_detail.valve = @new_valve
          new_detail.save!
        end
        logger.error "After Old Manufacturers Clone"
      end
      RecordChangelog.enable_recording = true
      # Custom revision history record
      RecordChangelog.record_creation(@new_valve, {
        :action => 'Cloned',
        :field_name => 'Valve',
        :old_value => self.valve_code,
        :new_value => @new_valve.valve_code
      })
      return @new_piping_class
     rescue ActiveRecord::RecordInvalid
    ensure
      # Be sure to re-enable recording even if this fails.
      RecordChangelog.enable_recording = true
      return @new_valve
  end

  	# Sets the archived variable to true and saves the valve.
  	def archive
    	self.archived = true
    	self.save
  	end
    def unarchive
      self.archived = false
      self.save
    end

  	def sext_data(options = {})
		if(options[:all])
			json = {}
			json[:id] = self.id
			json[:valve_code] = self.valve_code
		else
		    json = super()
		    json[:valve_note_short] = self.chopped_valve_note
			json[:valve_components] = []
			json[:manufacturers_valves] = []
			json[:valve_component_names] = []
			json[:comments] = self.comments
			json[:type] = self.valve_type
			json[:rating] = self.valve_rating
			json[:body] = self.valve_body

#		self.manufacturers_valves.each do |manuf_valve|
#			manuf = manuf_valve.manufacturer
#			if manuf.present?
#				json[:manufacturers_valves] << {
#					:id => manuf_valve.id,
#					:name => manuf.name,
#					:figure_no => manuf_valve.figure_no,
#					:manufacturer_id => manuf.id,
#					:valve_id => self.id
#				}
#			end
#		end

		# Does a select for each valve with this call, unfortunately..
#		self.valves_valve_components.each do |vvc|
#			comp = vvc.valve_component
#		self.valve_components.find(:all,
#		    :order => 'order_numbering ASC').each do |comp|

#			json[:valve_components] << comp.id
#			json[:valve_component_names] << {
#				:id => comp.vvc_id,
#				:valve_component_id => comp.id,
#				:component_name => comp.component_name,
#				:component_text => comp.component_text,
#				:valve_code => self.valve_code,
#				:valve_id => comp.valve_id
#			}

			# Adds TYPE, RATING, and BODY for Valves grid columns.
#			if comp.component_name == 'TYPE'
#				json[:type] = vvc.component_text
#			elsif comp.component_name == 'RATING'
#				json[:rating] = vvc.component_text
#			elsif comp.component_name == 'BODY'
#				json[:body] = vvc.component_text
#			end
#		end

	  	# Populates :references_data with an array of piping_reference attributes for
	  	# listing the references of valves. Defined in PipingReferenceHelper module.
#	  	json[:references_data] = self.get_piping_references
		end
  		return json
	end

    # Chops off the valve_note string at 200 chars. If it goes over, adds "..."
    def chopped_valve_note
        if !self.valve_note.blank? && self.valve_note.length > 200
            return self.valve_note[0..200] + "..."
        end
        return self.valve_note
    end

    def add_or_create_manufacturer(manufacturer, figure_no)
		@manufacturer = Manufacturer.find_by_id(manufacturer)

		if @manufacturer.blank? && manufacturer.to_i == 0 # which means its a non-numeric string
			@manufacturer = Manufacturer.find_by_name(manufacturer)
			if @manufacturer.blank?
				@manufacturer = Manufacturer.create!(:name => manufacturer)
			end
		end
		if @manufacturer.present?
			self.manufacturers_valves.create!(:manufacturer => @manufacturer, :figure_no => figure_no)
		end
   	end
end
