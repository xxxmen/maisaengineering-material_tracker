# == Schema Information
# Schema version: 20090730175917
#
# Table name: baskets
#
#  id          :integer(4)    not null, primary key
#  employee_id :integer(4)    
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Basket < ActiveRecord::Base
  belongs_to :employee
  has_many :basket_items, :dependent => :destroy
  
  validates_presence_of :employee_id
  
  def self.for_employee(employee)
    employee.basket || employee.create_basket
  end
end
