class MaterialRequestAttachment < ActiveRecord::Base
	############################################################################
	# ASSOCIATIONS
	############################################################################
	belongs_to :material_request
	has_attached_file :attachment, 
		:path => ":rails_root/data/material_request_attachments/:id_partition/:basename.:extension",
		:url => "/material_request_attachments/view/:id"
		
	############################################################################
	# INSTANCE METHODS
	############################################################################
	
	def filename
		self.attachment.original_filename
	end
	
	def path
		self.attachment.path
	end
end
