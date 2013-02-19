# == Schema Information
# Schema version: 20090730175917
#
# Table name: requested_line_items
#
#  id                   :integer(4)    not null, primary key
#  item_no              :integer(4)    
#  quantity             :integer(4)    
#  unit_of_measure      :string(255)   
#  material_description :text          
#  notes                :string(255)   
#  material_request_id  :integer(4)    
#

class RequestedLineItem < ActiveRecord::Base
  acts_as_list :scope => :material_request, :column => "item_no"

  before_save :check_blank_entry
  belongs_to :material_request
  has_many :ordered_line_items

  validates_presence_of :material_description

  def initialize(*args)
    super
    self.unit_of_measure ||= "EA"
    self.quantity ||= 1
  end

  def unqualified?
    self.material_description.blank?
  end
  def remove_ordered_item
    self.ordered_line_item = nil
    self.ordered_line_item_id = nil
    self.save!
  end



  # ===============
  # = CSV support =
  # ===============
  comma do
    RequestedLineItem.column_names.each do |column_name|
      case column_name
        when 'delta'
          #skip
        when 'material_request_id'
          material_request 'Material_Request Description' do |m| m.try(:material_description)  end
        else
          send(column_name)
      end
    end
  end

  private
  # if the entry is blank, don't save it
  def check_blank_entry
    !self.material_description.blank?
  end
end
