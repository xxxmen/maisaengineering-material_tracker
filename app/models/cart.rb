# == Schema Information
# Schema version: 20090730175917
#
# Table name: carts
#
#  id                  :integer(4)    not null, primary key
#  employee_id         :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#  unit_id             :integer(4)
#  year                :string(255)
#  telephone           :string(255)
#  deliver_to          :string(255)
#  purchaser_id        :integer(4)
#  planner_id          :integer(4)
#  notes               :text
#  requested_by_id     :integer(4)
#  state               :integer(4)    default(0)
#  tracking_no         :string(255)
#  date_requested      :date
#  sent_at             :datetime
#  received_at         :datetime
#  need_by             :string(255)
#  material_request_id :integer(4)
#

# Carts are used to store line items, which represents an inventory item and quantity
# Every employee should have 0 or 1 active cart at a time
class Cart < ActiveRecord::Base
  extend Listable::ModelHelper

  # Using ThinkingSphinx now... (Adam - 2009-06-18)
  #  acts_as_ferret :fields => [:tracking_no, :deliver_to, :year, :unit_description, :requester_name]

  PERPAGE = 100

  validates_presence_of :employee_id

  belongs_to :requester, :class_name => "Employee", :foreign_key => "requested_by_id"
  belongs_to :planner, :class_name => "Employee", :foreign_key => "planner_id"
  belongs_to :employee
  belongs_to :unit
  has_many :cart_items, :dependent => :destroy
  has_many :events, :as => :recordable, :dependent => :destroy

  # Thinking Sphinx Config
  define_index do
    
  set_property :delta => true
	indexes :tracking_no
	indexes :deliver_to
	indexes :year
	indexes unit(:description), :as => :unit_description
	indexes [requester(:first_name), requester(:mi), requester(:last_name)], :as => :requester_name
	
  set_property :delta => true
  end


  after_update :update_event

  # Processing => The user is still adding items to the cart (shopping!)
  # Sent => The user is done adding items to the cart, it's frozen, and out for issue
  # Received => The desktop has picked up the cart's CSV file and entered it into the system
  states_for :state => ["Processing", "Sent", "Received"]
  validates_inclusion_of_state

  # Sets the default values for any web requests
  def initialize(*args)
    super
    self.year ||= Date.today.year
    self.requested_by_id ||= self.employee_id
  end

  # For the select_tag "need_by" field
  def self.need_by_opts
    [ ['', ''],
      ['30 Minutes', '30 Minutes'],
      ['1 Hour', '1 Hour'],
      ['2 Hours', '2 Hours'],
      ['3 Hours', '3 Hours'],
      ['4 Hours', '4 Hours']]
  end

  # Lists out all of the SENT or RECEIVED carts
  def self.list_issued_or_closed(*args)
    self.with_scope(:find => { :conditions => ["state = ? OR state = ?", Cart::SENT, Cart::RECEIVED] }) do
      self.list(*args)
    end
  end

  # Filters for the web request index page
  # Cart.filter(employee, {} || {:unit => 1} || {:requester => 1}, "all" || "created_me" || "mine" || "submitted" || "received")
  # This will list out all web requests which meet the conditions
  def self.filter(employee, params, status)
    status ||= 'mine'

    # First, determine conditions from the current 'status'
    conditions = case status
    when 'all'
      ['state != ?', Cart::PROCESSING]
    when 'created_me'
      ["employee_id = ? AND state != ?", employee.id, Cart::PROCESSING]
    when 'mine'
      ["requested_by_id = ? AND state != ?", employee.id, Cart::PROCESSING]
    when 'submitted'
      ["state = ?", Cart::SENT]
    when 'received'
      ["state = ?", Cart::RECEIVED]
    end

    # Next, determine if the list should be limited by requesters OR unit
    additional_scope = if params[:unit] && params[:requester]
      ['carts.unit_id = ? AND carts.requested_by_id = ?', params[:unit], params[:requester]]
    elsif params[:unit]
      ['carts.unit_id = ?', params[:unit]]
    elsif params[:requester]
      ['carts.requested_by_id = ?', params[:requester]]
    else
      '1 = 1'
    end

    # Finally, return the list of carts
    with_scope(:find => { :conditions => additional_scope }) do
      with_scope(:find => { :conditions => conditions }) do
        self.list(params, :include => [:requester, :unit], :order => "carts.id", :sort => "DESC")
      end
    end
  end

  # returns all units currently within the carts table
  def self.all_units
    if(Cart.count <= 0)
      return []
    end
    carts = Cart.find(:all, :select => "distinct(unit_id)")
    if(carts.blank? || carts.length == 0)
      return []
    else
      unit_ids = []
      carts.each do |cart|
        if(!cart[:unit_id].blank?)
           unit_ids << cart[:unit_id]
        end
      end
      res = Unit.find(unit_ids, :order => "description")
      if(res.blank?)
        return []
      else
        return res
      end
    end
  end

  # returns all employees currently within the carts table as a requester
  def self.all_requesters
    requester_ids = Cart.find(:all, :select => "distinct(requested_by_id)").map(&:requested_by_id)
    Employee.find(requester_ids, :order => "last_name", :select => "id, first_name, last_name, mi")
  end

  # Finds the last cart ordered by tracking and spits out a new, unique tracking #
  def self.newest_tracking
    cart = Cart.find(:first, :order => "tracking_no DESC", :conditions => "tracking_no like 'WR_____'") || Cart.new(:tracking_no => "WR00000")
    cart.tracking_no =~ /(\d+)$/

    tracking = $1.to_i + 1
    tracking = tracking.to_s

    size = tracking.length
    (5 - size).times do
      tracking = "0" + tracking
    end

    return "WR" + tracking
  end

  def unit_description
    unit ? unit.description : ""
  end

  # If there's a requestor, give his name
  # If you want the ID too, return the requester's name in format "NAME (ID)"
  def requester_name(with_id=false)
    if requester && with_id
      return requester.entire_name_with_id
    elsif requester
      return requester.entire_full_name
    else
      return ""
    end
  end

  # Finds the material request with the same tracking no
  def request
    return MaterialRequest.find_by_tracking(self.tracking_no)
  end

  # Creates or adds a CartItem to this Cart
  # If the item already exists, then just add to the quantity
  # If the item doesn't exist, then this will create the item and connect it to the cart
  def create_or_add(attributes)
    quantity, inventory_item_id = attributes[:quantity], attributes[:inventory_item_id]
    cart_item = cart_items.find(:first, :conditions => { :inventory_item_id => attributes[:inventory_item_id] })
    if cart_item
      cart_item.quantity += quantity.to_i
      cart_item.save
    else
      cart_item = self.cart_items.build(attributes)
      cart_item.save
    end
    return cart_item
  end

  # A cart is out of stock if any of the cart item's requested quantity exceeds the amount
  # that it has in inventory
  def out_of_stock?
    self.cart_items.any? do |cart_item|
      cart_item.quantity.to_i > cart_item.inventory_item.quantity_available
    end
  end

  # The first line item is used for the description
  def description
    if self.cart_items[0] && self.cart_items[0].inventory_item
      self.cart_items[0].inventory_item.description
    else
      ''
    end
  end

  # Creates a new material request based off of this cart's information, and then empties this cart by deleting its line items
  def send_as_material_request(note = nil)
    manual = MaterialRequest.new
    manual.description = "Description"
    manual.unit_id = self.unit_id
    manual.requested_by_id = self.requested_by_id
    manual.telephone = self.telephone
    manual.notes = note || self.notes
    manual.deliver_to = self.deliver_to
    manual.created_by = self.employee.id
    manual.drafted_by = self.employee.id
    manual.save!

    self.cart_items.each do |cart_item|
      manual.items.create!(:quantity => cart_item.quantity, :unit_of_measure => cart_item.inventory_item.unit_of_measure,
                                     :material_description => cart_item.inventory_item.description, :notes => cart_item.inventory_item.stock_no)
    end

    return manual
  end

  # If the current cart is out of stock, create a new manual material request and empty out the cart
  # Otherwise, create a new cart to act as this employee's current cart and change the state
  # of this cart to be SENT
  def send_request
    manual = nil

    if self.out_of_stock?
      manual = self.send_as_material_request
    else
      manual = self.send_as_material_request("All items available from inventory")
    end
    self.cart_items.each { |i| i.destroy } # clear the cart

    create_event
    return manual
  end

  # Returns the cart in CSV format for download
  def return_csv
    csv_header = 'id,stock_no,quantity,unit_of_measure,item_note,tracking_no,work_orders,ptm_no,employee_no,employee_name,employee_phone,planner_name,date_requested,date_needed,unit,turnaround_year,deliver_to,stage,request_note,web_request_code'
    web_request_code = "XPTWR" + Time.now.strftime("%m%d%y%H%M%S")   # a random string for warehouse's computer to download

    return csv_header + "\r\n" + self.cart_items.find(:all, :order => "cart_items.id").map { |i| i.to_csv_row(web_request_code) }.join("\r\n")
  end

  # A cart gets created when the user first clicks on 'Add Item to Web Request'
  # NOT when it gets submitted (it should happen when it gets submitted)
  # def create_event
  #   self.events.create(:description => "created new web request ##{self.tracking_no}")
  # end
  def create_event
    if !self.tracking_no.blank?
      self.events.create(:description => "submitted web request ##{self.tracking_no}")
    end
  end

  def update_event
    if !Event.recent_for?(self) && !self.tracking_no.blank? && !self.processing?
      self.events.create(:description => "updated web request ##{self.tracking_no}")
    end
  end
end
