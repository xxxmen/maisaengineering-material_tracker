class QuoteAttachment < ActiveRecord::Base
	############################################################################
	# ASSOCIATIONS
	############################################################################
	belongs_to :quote
	has_attached_file :attachment, 
		:path => ":rails_root/data/quote_attachments/:id_partition/:basename.:extension",
		:url => "/quote_attachments/view/:id"
		
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
