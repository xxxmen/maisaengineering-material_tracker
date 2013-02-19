# == Schema Information
# Schema version: 20090730175917
#
# Table name: ordered_line_items
#
#  id                     :integer(4)    not null, primary key
#  po_id                  :integer(4)    
#  line_item_no           :integer(4)    
#  description            :text          
#  quantity_ordered       :integer(4)    
#  quantity_received      :integer(4)    
#  item_price             :integer(10)   
#  date_received          :date          
#  date_back_ordered      :date          
#  notes                  :text          
#  lock_version           :integer(4)    default(0)
#  updated_at             :datetime      
#  unit_of_measure        :string(255)   
#  details                :string(255)   
#  requested_line_item_id :integer(4)    
#  location               :string(255)   
#  issued_date            :date          
#  issued_to_name         :string(255)   
#  issued_to_company      :string(255)   
#  issued_quantity        :integer(4)    
#

class OrderedLineItem < ActiveRecord::Base

  acts_as_log_edits
  acts_as_list :scope => :po_id, :column => :line_item_no

  extend Listable::ModelHelper
  PERPAGE = 100

  belongs_to :requested_line_item
  belongs_to :order, :class_name => "Order", :foreign_key => "po_id"

  # Thinking Sphinx Config
  define_index do
    # Columns
    indexes :line_item_no
    indexes :description
    indexes :unit_of_measure
    set_property :delta => true
  end


  after_save :update_order
  after_destroy :update_order

  validates_presence_of :po_id, :description, :quantity_ordered

  def validate
    if !self.issued_quantity.blank?
      if self.quantity_received.blank? || (self.quantity_received < self.issued_quantity)
        errors.add(:issued_quantity, 'cannot be larger than quantity received')
      end
    end
  end

  def update_order
    # Added because I was getting an "ActiveRecord::StaleObjectError"
    # at the end where we call `self.order.save!`
    self.order.reload

    self.order.updated_at = self.updated_at
    partially_received = false
    fully_received = true

    self.order.ordered_line_items.each do |item|

      qty_received = item.quantity_received.blank? ? 0 : item.quantity_received
      qty_ordered = item.quantity_ordered.blank? ? 0 : item.quantity_ordered
      if(qty_received > 0)
        partially_received = true
      end
      if((qty_received < qty_ordered) && (fully_received == true))
        fully_received = false
      end
    end

    if(fully_received)
      self.order.status_id = PoStatus.fully_received_id
      self.order.completed = true
    elsif(partially_received)
      self.order.status_id = PoStatus.partially_received_id
      self.order.completed = false
    end
    self.order.save!
  end
  def self.filter(order_id)
    self.with_scope(:find => { :conditions => ["po_id = ?", order_id] }) { yield }
  end

  def employee_name
    self.employee ? employee.full_name : "(Not Issued)"
  end

  # Sets the record as received on *date* 
  def mark_as_received(date = Date.today)
    self.quantity_received = self.quantity_ordered
    self.date_received = date
  end

  # Sets the record as issued on *date*
  def mark_as_issued(name, company, date = Date.today)
    self.issued_quantity = self.quantity_received
    self.issued_to_name = name
    self.issued_to_company = company
    self.issued_date = date
  end

  def issueable?
    if self.quantity_ordered == 0
      return false
    end

    if ((self.quantity_received == 0 || self.quantity_received.blank?) && self.date_received.blank?)
      return false
    end

    if ((self.quantity_received.blank? || self.quantity_received < self.quantity_ordered) && !self.date_received.blank?)
      return false
    end

    if !self.issued_date.blank? || !self.issued_quantity.blank?
      return false
    end

    return true
  end


  def quantities_for_list
    "#{self.quantity_ordered} (#{self.quantity_received || 0})"
  end

  def to_json_data
    json = {}
    json[:id] = self.id
    json[:description] = self.description
    json[:line_item_no] = self.line_item_no
    json[:unit_of_measure] = self.unit_of_measure
    json[:quantity_ordered] = self.quantity_ordered
    json[:quantity_received] = self.quantity_received
    json[:date_received] = self.date_received
    json[:date_back_ordered] = self.date_back_ordered
    json[:location] = self.location
    json[:issued_to_name] = self.issued_to_name
    json[:issued_to_company] = self.issued_to_company
    json[:issued_date] = self.issued_date
    json[:notes] = self.notes
    json[:issued_quantity] = self.issued_quantity
    return json
  end

  # Updates the line item and splits it into duplicate line items with the same line item number but different quantities.
  # This allows for easier line item partial-ization based on the ordered, received, and issued quantities.
  # See Rails.root/spec/models/ordered_line_item_spec.rb for test cases.
  def update_attributes_with_splitting(attrs = {})
    self.attributes = attrs
    raise ActiveRecord::RecordInvalid, self unless self.valid?
    if !self.quantity_received.blank? && self.quantity_received > 0
      if !self.issued_quantity.blank?
        if self.quantity_ordered > self.quantity_received
          if self.quantity_received == self.issued_quantity
            new_quantity = self.quantity_ordered - self.quantity_received
            self.quantity_ordered = self.quantity_received
            duplicate(new_quantity)
          elsif self.quantity_received > self.issued_quantity
            qty_not_received = self.quantity_ordered - self.quantity_received
            qty_not_issued = self.quantity_received - self.issued_quantity
            qty_issued = self.issued_quantity
            self.quantity_ordered = qty_issued
            self.quantity_received = qty_issued
            self.date_received = nil
            self.date_back_ordered = nil
            duplicate(qty_not_issued, qty_not_issued)
            duplicate(qty_not_received)
          end
        elsif self.quantity_received > self.issued_quantity
          if self.quantity_ordered == self.quantity_received
            qty_not_issued = self.quantity_received - self.issued_quantity
            qty_issued = self.issued_quantity
            self.quantity_ordered = qty_issued
            self.quantity_received = qty_issued
            duplicate(qty_not_issued, qty_not_issued)
          elsif self.quantity_ordered < self.quantity_received
            if  self.quantity_ordered > self.issued_quantity
              new_ordered_qty = self.quantity_ordered - self.issued_quantity
              new_received_qty = self.quantity_received - self.issued_quantity
              self.quantity_ordered = self.issued_quantity
              self.quantity_received = self.issued_quantity
              duplicate(new_ordered_qty, new_received_qty)
            else
              qty_not_issued = self.quantity_received - self.issued_quantity
              self.quantity_received = self.issued_quantity
              duplicate(0, qty_not_issued)
            end
          end
        end
      elsif self.quantity_ordered > self.quantity_received
        new_quantity = self.quantity_ordered - self.quantity_received
        self.quantity_ordered = self.quantity_received
        duplicate(new_quantity)
      end
    end

    if self.save
      return true
    else
      return false
    end
  rescue ActiveRecord::RecordInvalid => e
    return false
  end

  # Added by Adam Grant to return last number in the list (12/5/08)
  def last_position_in_list
    return nil unless in_list?
    bottom_position_in_list
  end

  # ===============
  # = CSV support =
  # ===============
  comma do
    OrderedLineItem.column_names.each do |column_name|
      case column_name
        when 'delta'
          #skip
        when 'po_id'
          order 'PO Number' do |o| o.try(:po_no)  end
        when 'requested_line_item_id'
          requested_line_item 'Requested Line Item Description' do |m| m.try(:material_description)  end
        else
          send(column_name)
      end
    end
  end


  private

  # Used for duplicating the line item but with different quantities specified.
  def duplicate(qty_ordered, qty_received = nil, qty_issued = nil)
    new_item = OrderedLineItem.create!(self.attributes.merge({
                                                                 :quantity_ordered => qty_ordered,
                                                                 :quantity_received => qty_received,
                                                                 :issued_quantity => qty_issued,
                                                                 :date_received => nil
                                                             }))
    new_item.line_item_no = self.line_item_no
    new_item.save!
  end

end
