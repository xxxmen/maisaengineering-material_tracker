# == Schema Information
# Schema version: 121
#
# Table name: ordered_line_items
#
#  id                     :integer(11)   not null, primary key
#  po_id                  :integer(11)   
#  line_item_no           :integer(11)   
#  description            :text          
#  quantity_ordered       :integer(11)   
#  quantity_received      :integer(11)   
#  item_price             :integer(10)   
#  date_received          :date          
#  date_back_ordered      :date          
#  notes                  :text          
#  lock_version           :integer(11)   default(0)
#  updated_at             :datetime      
#  unit_of_measure        :string(255)   
#  class                  :string(255)   
#  details                :string(255)   
#  requested_line_item_id :integer(11)   
#  location               :string(255)   
#  issued_date            :date          
#  issued_to_name         :string(255)   
#  issued_to_company      :string(255)   
#  issued_quantity        :integer(11)   
#
#  validates_presence_of :po_id, :description, :quantity_ordered
#

class OrderedLineItem < ActiveRecord::Base  
    generator_for :description, 'This is an ordered line item.'
    
    generator_for :tracking, :start => 1 do |prev|
        prev++
    end
end


