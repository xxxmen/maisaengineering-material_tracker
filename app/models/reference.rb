# == Schema Information
# Schema version: 20090730175917
#
# Table name: refs
#
#  id           :integer(4)    not null, primary key
#  parent_id    :integer(4)    
#  content_type :string(255)   
#  filename     :string(255)   
#  size         :integer(4)    
#  folder_id    :integer(4)    
#  search_terms :text          
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Reference < ActiveRecord::Base
  # Using ThinkingSphinx now... (Adam - 2009-06-18)    	
  # acts_as_ferret :fields => [:search_terms, :filename]
  extend Listable::ModelHelper
  PERPAGE = 100
  
  set_table_name :refs
  validates_presence_of :folder_id
  belongs_to :folder
  before_validation { |r| r.folder_id ||= 1 }

  #has_attachment_file :storage => :file_system,
  #              :path_prefix => "refs"


  	# Thinking Sphinx Config
#	define_index do
#		indexes :search_terms
#		indexes :filename
#		set_property :delta => :datetime, 
#			:threshold => 1.minute, 
#			:delta_column => :updated_at		
#	end                 
end
