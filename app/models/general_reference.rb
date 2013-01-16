class GeneralReference < ActiveRecord::Base
    ###########################################################################
    # MIXINS
    ###########################################################################
    extend Listable::ModelHelper
  
    
    ###########################################################################
    # CONSTANTS
    ###########################################################################
    PERPAGE = 100
  
    
    ###########################################################################
    # ASSOCIATIONS
    ###########################################################################
  	has_attached_file :reference, 
		:path => ":rails_root/data/general_references/:id_partition/:basename.:extension",
		:url => "/general_references/download/:id"

    
  
    ###########################################################################
    # THINKING SPHINX CONFIG
    ###########################################################################
	define_index do
		indexes :reference_file_name
		
        set_property :delta => true
	end                 
end
