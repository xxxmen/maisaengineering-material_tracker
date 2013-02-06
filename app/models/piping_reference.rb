# == Schema Information
# Schema version: 20090730175917
#
# Table name: assets
#
#  id                :integer(4)    not null, primary key
#  data_file_name    :string(255)   
#  data_content_type :string(255)   
#  data_file_size    :integer(4)    
#  attachings_count  :integer(4)    default(0)
#  created_at        :datetime      
#  data_updated_at   :datetime      
#  asset_type        :string(255)   
#  description       :string(255)   
#  custom_link       :string(255)   
#  updated_at        :datetime      
#  created_by        :string(255)   
#  updated_by        :string(255)   
#  show_public_link  :boolean(1)    
#

# Used for attaching files to models in the POPV webspace (PipingClasses, Valves, etc.)
class PipingReference < ActiveRecord::Base

	############################################################################	
  	# CONSTANTS
	############################################################################

	FILE_TYPE = 'File'
	LINK_TYPE = 'Link'

    PAGE_LIMIT = 40
#    PAGE_INCLUDE = [:bill_items, :piping_class_details, :employees]
#    PAGE_ORDER_MAPPING = {  :num_items => "(SELECT COUNT(*) AS user_count FROM bill_items AS b1 WHERE b1.bill_id = bills.id)", :created_name => 'employees.last_name' }
    SEXT_SEARCH_FIELDS = ['description', 'data_file_name', 'custom_link', 'reference_type']

	############################################################################	
  	# ASSOCIATIONS
	############################################################################
  	
	# New Attachment stuff, with Paperclip and PaperclipPolymorph:
	has_attached_file :data, 
		:path => ":rails_root/data/piping_references/:id_partition/:basename.:extension",
		:url => "/piping_references/view/:id"
	has_many :attachings, :class_name => "PipingReferenceAttaching", :dependent => :destroy

	############################################################################	
  	# VALIDATIONS
	############################################################################

	validates_presence_of :description, :reference_type
	
	# If both are empty, alerts on both fields.
	validates_presence_of :custom_link, :if => Proc.new {|piping_reference| !piping_reference.data.file? }, 
		:message => "must have either a custom link or a file attachment"
	validates_attachment_presence :data, :if => Proc.new {|piping_reference| piping_reference.custom_link.blank? },
		:message => "must have either a custom link or a file attachment"
		
	# If both have been filled out, alerts on both fields.	
	def validate
		if (self.custom_link.present? && self.data.file?)
			errors.add(:custom_link, "cannot have both a Link and a File")
			errors.add(:data, "cannot have both a Link and a File")
		end
	end
	
	############################################################################	
  	# CALLBACKS
	############################################################################

	before_validation :set_description, :get_reference_type

	############################################################################	
  	# CLASS METHODS
	############################################################################

	# Grabs PipingReferences with "show_public_link" set to "true" for showing under
	# the "References" section of WebPOPV.
	def self.list_public_links
		self.find(:all, :conditions => {:show_public_link => true}, :order => 'description ASC')
	end

	############################################################################	
  	# INSTANCE METHODS
	############################################################################

	def initialize(*args)
		super(*args)
	end
		

	def sext_data(hash = {})
		data = super(hash)
		data['description'] = self.description || " "
		data['filename'] = self.filename
		data['reference_type'] = self.reference_type || self.get_reference_type
		data['reference'] = self.reference
		data['file_link'] = self.reference_type == FILE_TYPE ? self.data.url : ""
		data['created_at'] = self.created_at ? self.created_at.to_formatted_s(:default) : ""
		data['updated_at'] = self.updated_at ? self.updated_at.to_formatted_s(:default) : ""
		data['link'] = self.link
		data['show_public_link'] = self.show_public_link
		data['attachings'] = []
		self.attachings.each do |attachment|
			 
			data['attachings'] << {
				:model => attachment.attachable_type, 
				:description => attachment.attachable ? attachment.attachable.piping_reference_identifier : "Record doesn't exist any longer."
			}
		end
		data['attachings_count'] = self.attachings.size
		data
	end

	# Assigns the type to reference_type
	def get_reference_type
		if is_link?
			self.reference_type = LINK_TYPE
		elsif is_file?
			self.reference_type = FILE_TYPE
		end
	end

	def link
		self.reference_type == FILE_TYPE ? self.data.url : self.custom_link
	end

	# Checks if PipingReference is a file
	def is_file?
		self.data.file? && self.custom_link.blank?
	end
	
	# Checks if PipingReference is a link
	def is_link?
		!self.data.file? && self.custom_link.present?
	end
	
	# Returns an identifier: data_file_name for a file, or custom_link for a link.
	def reference
		if is_file?
			self.data_file_name
		else
			self.custom_link
		end
	end

	def save_with_attaching(params)
		attaching = nil
		transaction do 
			self.attributes = {
				:description => params[:description],
				:custom_link => params[:custom_link],
				:data => params[:data]
			}
			self.save!
			attaching = build_attachment(params)
			attaching.save!
		end
		true
	rescue ActiveRecord::RecordInvalid
		if attaching
			attaching.errors.each do |attr, msg|
				self.errors.add(attr, msg)
			end
		end
		false
	end

	def path
		self.is_file? ? self.data.path : ''
	end

	def read
		if self.is_file?
			File.new(self.data.path).read
		else
			''
		end
	end

	# From Original Polymorphic Paperclip Plugin PipingReference Model (don't modify unless
	# absolutely necessary)
	############################################################################	
	# has_attached_file :data,
	#     :styles => { 
	#		   :tiny => "64x64#",
	#     	   :small => "176x112#",
	#          :medium => "630x630>",
	#          :large => "1024x1024>" 
	#     }

	def url(*args)
		data.url(*args)
	end

	def name
		data_file_name
	end

	def content_type
		data_content_type
	end

	def browser_safe?
		%w(jpg gif png).include?(url.split('.').last.sub(/\?.+/, "").downcase)
	end
	alias_method :web_safe?, :browser_safe?

	# This method will replace one of the existing thumbnails with an file provided.
	def replace_style(style, file)
		style = style.downcase.to_sym
		if data.styles.keys.include?(style)
		    if File.exist?(Rails.root + '/public' + a.data(style))
		    end
		end
	end

	# This method assumes you have images that corespond to the filetypes.
	# For example "image/png" becomes "image-png.png"
	def icon
		"#{data_content_type.gsub(/[\/\.]/,'-')}.png"
	end
	
	def detach(attached)
		a = attachings.find(:first, :conditions => ["attachable_id = ? AND attachable_type = ?", attached, attached.class.to_s])
		raise ActiveRecord::RecordNotFound unless a
		a.destroy
	end
	############################################################################
	# End of Original Polymorphic Paperclip Plugin PipingReference Model
  
   	alias_method :filename, :name
	
	############################################################################
	private
	
	# Sets the description to the filename if the PipingReference is a file and the 
	# description is blank.
 	def set_description
 		if self.description.blank? && self.is_file?
 			self.description = self.filename	
		end	
	end
	
	def build_attachment(options = {})
		self.attachings.build({
				:attachable_type => options[:attachable_type],
				:attachable_id => options[:attachable_id]
		})		
	end
end

