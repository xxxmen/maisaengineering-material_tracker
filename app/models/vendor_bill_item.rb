# == Schema Information
# Schema version: 20090730175917
#
# Table name: vendor_bill_items
#
#  id           :integer(4)    not null, primary key
#  bill_id      :integer(4)    
#  bill_item_id :integer(4)    
#  vendor_id    :integer(4)    
#  notes        :text          
#  price        :string(255)   
#  availability :date          
#

class VendorBillItem < ActiveRecord::Base
  belongs_to :bill
  belongs_to :bill_item
  belongs_to :vendor

  before_validation(on: :create) do
    self.bill_id = self.bill_item.bill.id
  end

  validates_presence_of :bill_id, :bill_item_id, :vendor_item_id
end
