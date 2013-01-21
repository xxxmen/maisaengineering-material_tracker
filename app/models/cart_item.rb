# == Schema Information
# Schema version: 20090730175917
#
# Table name: cart_items
#
#  id                :integer(4)    not null, primary key
#  quantity          :integer(4)    
#  cart_id           :integer(4)    
#  inventory_item_id :integer(4)    
#  created_at        :datetime      
#  updated_at        :datetime      
#  notes             :text          
#

class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :inventory_item
  
  validates_presence_of :cart_id, :quantity, :inventory_item_id
  validates_numericality_of :quantity
  
  def validate
    errors.add(:quantity, "must be greater than 0") if self.quantity.to_i <= 0
  end  
    
  def to_json
    return {
      :quantity => quantity,
      :description => self.inventory_item.description,
      :unit_of_measure => self.inventory_item.unit_of_measure
    }.to_json
  end
  
  def stock_no
    self.inventory_item ? self.inventory_item.stock_no : ""
  end
    
  def to_csv_row(web_request_code)
    web_request_code ||= "XPTWR" + Time.now.strftime("%m%d%y%H%M%S")   # a random string for warehouse's computer to download
    
    # took out work_orders, ptm_no, stage_location
    [self.id, self.stock_no, self.quantity, self.inventory_item.unit_of_measure,
     self.notes, self.cart.tracking_no, '', '',
     self.cart.requester.badge_no, self.cart.requester.full_name, self.cart.requester.telephone,
     '', self.cart.date_requested, cart.need_by,
     self.cart.unit.description, self.cart.year, self.cart.deliver_to, '',
     self.cart.notes, web_request_code].map { |c| c.to_s.gsub(',', '&#44;') }.join(",")
  end
end
