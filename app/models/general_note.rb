# == Schema Information
# Schema version: 20090730175917
#
# Table name: general_notes
#
#  id           :integer(4)    not null, primary key
#  created_at   :datetime      
#  section_name :string(255)   
#  section_no   :integer(4)    
#  section_text :text          
#  updated_at   :datetime      
#

class GeneralNote < ActiveRecord::Base
	has_many :user_notes, :as => :table
end
