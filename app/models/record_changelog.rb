#
#    t.string   "record_type"
#    t.integer  "record_id"
#    t.string   "field_name"
#    t.text     "old_value"
#    t.text     "new_value"
#    t.datetime "modified_at"
#    t.integer  "employee_id"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#

class RecordChangelog < ActiveRecord::Base
	cattr_accessor :enable_recording
	has_attached_file :attachment, 
		:path => ":rails_root/data/changelog_attachments/:id_partition/:basename.:extension",
		:url => "/record_changlogs/get_attachment/:id"


	@@enable_recording = true
	
  	############################################################################
  	# CONSTANTS
  	############################################################################
	PAGE_ORDER_MAPPING = {:modified_by => 'employees.last_name'}
	
	ACTIONS = [
		'Created',
		'Updated',
		'Deleted'
	]
	
  	############################################################################
  	# ASSOCIATIONS
  	############################################################################

#	belongs_to :record, :polymorphic => true
#	belongs_to :employee

  	############################################################################
  	# VALIDATIONS
  	############################################################################
  	validates_presence_of 	:record_type, 
  							:record_identifier, 
  							:action,
  							:modified_at
  							
  	############################################################################
  	# CALLBACKS
  	############################################################################
  	before_create {|record| record.modified_at ||= Time.now }
  	
	
  	############################################################################
  	# CLASS METHODS
  	############################################################################

	def self.record_changes(obj, options = {})
		if @@enable_recording
			obj.changes.each do |key, value|
				field_name = key.humanize
				if key =~ /(_id)$/i
					obj.class.reflections.each_pair do |assoc, reflection| 
						if reflection.macro == :belongs_to && reflection.primary_key_name == key
							if value[0].present?
								value_0 = reflection.class_name.constantize.find_by_id(value[0])
								value[0] = value_0 ? value_0.record_changelog_identifier : value[0]
							end
							if value[1].present?
								value_1 = reflection.class_name.constantize.find_by_id(value[1])
								value[1] = value_1 ? value_1.record_changelog_identifier : value[1]
							end
							field_name = reflection.name.to_s.humanize
							break
						end
					end
				end
				self.create!({
					:record_id => obj.id,
					:record_type => obj.class.to_s.titleize,
					:record_identifier => obj.record_changelog_identifier,
					:action => 'Updated',
					:field_name => field_name,
					:old_value => (value[0].present? ? value[0] : ""),
					:new_value => (value[1].present? ? value[1] : ""),
					:modified_by => Employee.current_employee_name,
					:modified_at => Time.now
				}.merge(options))
			end
		end
	end
	
	def self.record_creation(obj, options = {})
		if @@enable_recording
			self.create!({
				:record_id => obj.id,
				:record_type => obj.class.to_s.titleize,
				:record_identifier => obj.record_changelog_identifier,
				:action => 'Created',
				:modified_by => Employee.current_employee_name,
				:modified_at => Time.now
			}.merge(options))
		end
	end

	def self.record_deletion(obj, options = {})
		if @@enable_recording
			self.create!({
				:record_id => obj.id,
				:record_type => obj.class.to_s.titleize,
				:record_identifier => obj.record_changelog_identifier,
				:action => 'Deleted',
				:modified_by => Employee.current_employee_name,
				:modified_at => Time.now
			}.merge(options))
		end
	end

	def self.enable_recording
		@@enable_recording
	end
	
	def self.enable_recording=(value)
		if value == false
			@@enable_recording = false
		else
			@@enable_recording = true
		end
	end

	# Accepts a block to turn off recording changes within.
	def self.disable_recording &block
		self.enable_recording = false
		yield
		self.enable_recording = true
	end

  	############################################################################
  	# INSTANCE METHODS
  	############################################################################

	def sext_data(options = {})
		data = super(options)
		data['attachment_url'] = self.attachment.blank? ? '' : self.attachment.url
		data['modified_at'] = self.modified_at.to_formatted_s(:date_only)
		data
	end
	
	def update_comment(new_comment)
		self.comment = new_comment
		self.save!
	end
end
