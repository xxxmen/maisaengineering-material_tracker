# Adam Grant (07/15/2009)
# This helper module should be included into any ActiveRecord models that have piping_references
# and want to display them in ExtJS.
module PipingReferenceHelper
	# Loops through an object's attachings, populating an array with
	# the attributes of the associated piping_references. For use mainly in a sext_data 
	# method call.
	def get_piping_references
		if (self.piping_reference_attachings.size <= 0)
  			''
  		else  		
  			refs = []
  			self.piping_reference_attachings.each do |piping_reference_attaching|
  				data = piping_reference_attaching.piping_reference.sext_data
  				data = data.merge({'piping_reference_attaching_id' => piping_reference_attaching.id})
  				refs << data
 			end
 			refs
		end
	end
	
	def piping_reference_identifier
		''
	end
	
end
