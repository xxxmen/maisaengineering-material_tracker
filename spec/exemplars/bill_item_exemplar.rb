# == Schema Information
# Schema version: 121
#
# Table name: bill_items
#
#  id                     :integer(11)   not null, primary key
#  bill_id                :integer(11)   
#  quantity               :integer(11)   
#  piping_class_detail_id :integer(11)   
#  item_no                :integer(11)   
#  unit_of_measure        :string(255)   
#  description            :text          
#  notes                  :text          
#  manual                 :boolean(1)    
#  created_at             :datetime      
#  updated_at             :datetime      
#  size_1                 :string(255)   
#  size_2                 :string(255)   
#  line_num               :integer(11)   
#

class BillItem < ActiveRecord::Base  
    generator_for :description, :start => "A description 1" do |prev|
    	prev.succ
   	end
    
    generator_for :manual, 1
end

