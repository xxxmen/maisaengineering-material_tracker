# == Schema Information
# Schema version: 20090730175917
#
# Table name: units
#
#  id           :integer(4)    not null, primary key
#  description  :string(80)    
#  lock_version :integer(4)    default(0)
#  updated_at   :datetime      
#  created_at   :datetime      
#  unit_no      :string(255)   
#

class Unit < ActiveRecord::Base
    extend Listable::ModelHelper
    
    PERPAGE = 100
    SEXT_INCLUDE = []
  
    # Configures the DB query to sort the unit_no correctly. Places numerical unit_no's
    # at the top, formatted to 4 chars with front padding of zeros. Places
    # units with alpha char unit_no's after those, then ones without unit_no's
    # at the very end.
    SEXT_SELECT_FIELDS = "id, delta, description, unit_no, lock_version, updated_at, created_at, unit_no, if(unit_no is null,'Z000',RIGHT(CONCAT('Z000', trim(unit_no)),4)) as ordered_number, IF(unit_no = '' OR unit_no IS NULL, description,CONCAT(IF(IF(unit_no IS NULL,'Z000',RIGHT(CONCAT('Z000', TRIM(unit_no)),4))='Z000','',IF(unit_no is null,'Z000',RIGHT(CONCAT('Z000', TRIM(unit_no)),4))),' : ', description)) as full_description"
  

	# Using ThinkingSphinx now... (Adam - 2009-06-18)    
    # acts_as_ferret :fields => [:description]
    acts_as_log_edits
  
    has_many :orders
    has_many :bills
  
  	# Thinking Sphinx Config
	define_index do
		indexes :description
		set_property :delta => true
	end
  
    validates_presence_of :description
    validates_uniqueness_of :description   
    
    def request_count(humanize = false)
        @count_for_request ||= MaterialRequest.count(:conditions => ["unit_id = ?", self.id])
        if humanize
            @count_for_request.to_s + " Requests"
        else
            @count_for_request
        end
    end
    
    def po_count(humanize = false)
        @count_for_po ||= Order.count(:conditions => ["unit_id = ?", self.id])
        if humanize
            @count_for_po.to_s + " Orders"
        else
            @count_for_po
        end
    end
  
    def self.list_units
        Unit.find(:all, :order => "description ASC").map { |u| [u.description, u.id] }.unshift([nil, nil])
    end  
  
    def sext_data(options = {})
  	    json = super(options)
  	    
  	    # I realize that I could concatenate the unit_no and description here,
  	    # instead of doing it in SQL (see SEXT_SELECT_FIELDS above), but 
  	    # that's how it is. Faster to do it in SQL anyway. Although for the
  	    # number of units they have (~500), not a huge performance hit either way.
  	    if self.respond_to?(:full_description)
  	        json[:full_description] = self.full_description
        elsif self.unit_no.blank?
            json[:full_description] = self.description    
        else
            json[:full_description] = "#{self.unit_no} : #{self.description}"
        end
  	    return json
    end

    def number_and_description
        if self.unit_no.blank?
            self.description
        else
            self.unit_no + ' : ' + self.description
        end
    end
  
end
