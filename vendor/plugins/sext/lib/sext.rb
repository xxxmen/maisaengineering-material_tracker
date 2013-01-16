# includes common methods to extract data from active record models
class ActiveRecord::Base
  # Extracts any data from an ActiveRecord object and returns the data in hash format.
  #
  # options are:
  #   :except => array of attributes to NOT include
  #   :only => array of attributes to include
  # NOTE that only one of except or only should be used, if both are given only will take precedence
  def sext_data(options = {})
    json = Sext.sext_data(self)
#  	if !options[:all] && !options[:all_index]
#	    if(self.class.reflect_on_association(:user_notes))
#	    	if(!json[:user_note_data])
#	    		json[:user_note_data] = []
#	    	end
#	    	if(self.user_notes.size > 0)
#	    		self.user_notes.each do |note|
#	    		  if(note.hidden == false)
#			      	json[:user_note_data] << note.sext_data
#		      	  end
#		    	end
#	    	else
#	    		
#			end
#		end
#	end

    return json
  end
  
  	def get_user_note_data
  		user_note_data = []
  		if self.class.reflect_on_association(:user_notes)
	    	self.user_notes.each do |note|
	    	  	if note.hidden == false
			      	user_note_data << note.sext_data
		      	end
		    end
		end
  		user_note_data
 	end
end
# Sext
module Sext
  # extract the client data from an array of active record objects
  def self.get_data(records, get_related_data = true, options = {})
	if records.size == 0
		[]
	else
      	records.map do |r|
      		records_data = {}
      		
      		if r.respond_to?(:sext_data)
	        	records_data = r.sext_data(options)
	        	records_data[:id] ||= r.id
	        else
	        	records_data = Sext.sext_data(r)
	       	end
        	
        	if get_related_data
	            records_data[:related_data] = r.sext_related_data if r.respond_to?(:sext_related_data)
	        end

        	records_data
      	end
    end


  	
#    if records.size == 0
#      []
#    elsif records.all? { |r| r.respond_to?(:sext_data) }
#      # if it defines sext_data, return that
#      records.map do |r|
#        records_data = r.sext_data(options)
#        records_data[:id] ||= r.id
#        if(get_related_data)
#            records_data[:related_data] = r.sext_related_data if r.respond_to?(:sext_related_data)
#        end
#        records_data
#      end
#    else
#      # otherwise just return all of its attributes
#      attributes = records[0].class.columns.map{|c| c.name if(c.type != :binary)}.delete_if{|i| i.nil?}
#      records.map do |r|
#        records_data = {}
#        attributes.each do |a| 
#          records_data[a] = r.send(a)
#          
#        end
#        if(get_related_data)
#            records_data[:related_data] = r.sext_related_data if r.respond_to?(:sext_related_data)
#        end
#        records_data
#      end
#    end
#    
  end
  
  def self.associated_column_nice_name(associated_object_name)
    nice_name = ''
      assoc_object_klass = Module.const_get(associated_object_name)
      assoc_object_columns = assoc_object_klass.columns.delete_if { |c| c.name == "id" || c.name =~ /_id$/ || c.name == "updated_at" || c.name == "created_at" }
      assoc_object_columns.each do |column|
        if(nice_name == '')
            nice_name = column.name
        end
        if(column.name.include?('name'))
            nice_name = column.name
        elsif(column.name.include?('description'))
        	#let any 'name' override description
        	if(!nice_name.include?('name'))
            	nice_name = column.name
            end
        end
      end
      if(nice_name == '')
        nice_name = 'id'
      end
      
      return nice_name
      
      rescue
        return 'id'
  end
  def self.sext_data(obj, *attributes)
    records_data = {}
    attributes = obj.class.columns.map{|c| c.name if(c.type != :binary)}.delete_if{|i| i.nil?} if attributes.size == 0
    attributes.each { |a| records_data[a] = obj.send(a) }
    return records_data
  end
  
  # determine what to join in SQL statement
  def self.get_joins(klass)
    if klass.const_defined?("SEXT_INCLUDE")
      return klass.const_get("SEXT_INCLUDE")
    else
      klass.reflect_on_all_associations.map(&:name)
    end
  end
end


