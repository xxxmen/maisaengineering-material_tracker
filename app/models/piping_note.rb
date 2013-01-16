# == Schema Information
# Schema version: 20090730175917
#
# Table name: piping_notes
#
#  id          :integer(4)    not null, primary key
#  created_at  :datetime      
#  note_text   :text          
#  updated_at  :datetime      
#  note_number :integer(4)    
#

class PipingNote < ActiveRecord::Base
    has_and_belongs_to_many :piping_class_detail, :join_table => :piping_notes_piping_class_details
    has_many :user_notes, :as => :table
    
    SEXT_INCLUDE = [:user_notes]
    SEXT_SEARCH_FIELDS = ['note_text','note_number']
        
    validates_presence_of :note_text, :note_number
    validates_numericality_of :note_number    
end
