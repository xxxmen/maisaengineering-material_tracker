# == Schema Information
# Schema version: 20090730175917
#
# Table name: basket_items
#
#  id                :integer(4)    not null, primary key
#  basket_id         :integer(4)    
#  inventory_item_id :integer(4)    
#  quantity          :integer(4)    
#  created_at        :datetime      
#  updated_at        :datetime      
#

class BasketItem < ActiveRecord::Base
  belongs_to :basket
  belongs_to :inventory_item
  
  validates_numericality_of :quantity
  validates_presence_of :quantity
  validates_presence_of :basket_id
  validates_presence_of :inventory_item_id
end

