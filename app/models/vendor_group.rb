# == Schema Information
# Schema version: 20110701220518
#
# Table name: vendor_groups
#
#  id                :integer(4)    not null, primary key
#  name              :string(255)   
#


class VendorGroup < ActiveRecord::Base
    ############################################################################
    # MIXINS
    ############################################################################

    extend Listable::ModelHelper
    
    ############################################################################
    # CONSTANTS
    ############################################################################

    PERPAGE = 100
    
    ############################################################################
    # INDEXING
    ############################################################################
    
    # Thinking Sphinx Config
    define_index do
        indexes :id
        indexes :name
#        set_property :delta => true
    end
	############################################################################
    # ASSOCIATIONS
    ############################################################################
    
    has_and_belongs_to_many :vendors
        
    ############################################################################
    # VALIDATIONS
    ############################################################################

    validates_presence_of :name
  
end
