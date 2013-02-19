# == Schema Information
# Schema version: 20090730175917
#
# Table name: purchase_orders
#
#  id                :integer(4)    not null, primary key
#  created           :date
#  tracking          :text
#  po_no             :text
#  description       :text
#  vendor_id         :integer(4)
#  status_id         :integer(4)    default(1)
#  deliver_to        :string(255)
#  work_orders       :string(255)
#  ptm_no            :text
#  awr               :boolean(1)
#  total_cost        :decimal(16, 2
#  unit_id           :integer(4)
#  turnaround_year   :text
#  date_eta          :date
#  completed         :boolean(1)
#  closed            :boolean(1)
#  location          :text
#  activity          :text
#  issued_to_history :text
#  lock_version      :integer(4)    default(0)
#  updated_at        :datetime
#  record_counter    :integer(4)
#  planner_id        :integer(4)
#  requested_by_id   :integer(4)
#  date_need_by      :date
#  date_requested    :date
#  stage             :boolean(1)
#  suggested_vendor  :string(255)
#  acknowledged      :boolean(1)
#  authorized        :boolean(1)
#  archived          :boolean(1)
#

class Order < ActiveRecord::Base
  extend Listable::ModelHelper

  acts_as_log_edits

  set_table_name "purchase_orders"

  attr_accessor :issued_to_employee,
                :issued_to_company,
                :issued_to_note,
                :issued_to_date,
                :issued_to_location,
                :status_set_to_fully_received,
                :eta_change_difference

  validates :po_no, :uniqueness => true, :allow_blank => true, :uniqueness => { :message => "is not a valid year" }
  validates :po_no, :on => :update, :presence => true
  validates :tracking, :unit_id, :presence => true
  validates :turnaround_year, :allow_blank => true, :numericality => true

  belongs_to :unit
  belongs_to :vendor
  belongs_to :status, :class_name => "PoStatus", :foreign_key => "status_id"
  belongs_to :planner, :class_name => "Employee", :foreign_key => "planner_id"
  belongs_to :requester, :class_name => "Employee", :foreign_key => "requested_by_id"
  belongs_to :group

  #has_many :assets, :as => :assetable
  has_many :reminders, :class_name => "Reminder", :foreign_key => "po_id"
  has_many :activities, :class_name => "Activity", :foreign_key => "po_id"
  has_many :ordered_line_items, :class_name => "OrderedLineItem", :foreign_key => "po_id", :order => "line_item_no"
  has_many :items_received_today, :class_name => "OrderedLineItem", :foreign_key => "po_id", :order => "line_item_no", :conditions => { :date_received => Date.today }
  has_many :events, :as => :recordable
  has_and_belongs_to_many :material_requests


  # Thinking Sphinx Config
  define_index do
    # Columns
    indexes :po_no
    indexes tracking
    indexes ptm_no
    indexes description
    indexes issued_to_history
    indexes location
    indexes work_orders

    # Associations
    indexes unit(:description), :as => :unit_name
    indexes vendor(:name), :as => :supplier

    set_property :delta => true
  end

  has_and_belongs_to_many :material_requests

  # Temporarily assign a tracking for now to blank ones
  before_validation(on: :update) do
    self.tracking = Order.newest_tracking unless attribute_present?("tracking")
  end
  before_create { |o| o.created ||= Date.today }
  after_create { |o| o.po_no.blank? ? o.po_no = "WTMP#{o.id}" : nil; o.save }
  before_save :format_description
  before_save :set_status

  after_create :create_event
  after_update :update_event
  after_update :update_reminders_if_eta_has_changed

  PERPAGE = 50

  def initialize(*args)
    super
    self.status_id ||= 5 # Ordered
    self.turnaround_year ||= Date.today.year
    self.group_id ||= Group.get_default_id
    @status_set_to_fully_received = false
  end

  # When writing the new ETA, it checks what the difference in days is
  # between the new one and the old ETA date, storing the value into
  # an instance variable "eta_change_difference". Used for updating the Reminders
  # attached to this Order after_update. See update_reminders_if_eta_has_changed
  def date_eta=(date)
    if !date.blank?
      new_date = date.class == String ? Date.parse(date) : date

      unless self[:date_eta].blank? || new_date.blank?
        difference = (self[:date_eta] - new_date).to_i
        self.eta_change_difference = difference unless difference == 0
      end
    end

    self[:date_eta] = date
  end

  def reminder_subject
    return "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] PO ##{self.po_no} Reminder"
  end

  def find_upcoming_reminders
    reminders.find(:all, :conditions => "sent_on IS NULL", :order => "send_reminder_on ASC")
  end

  ##
  #     update_activity(text as String) => true / false
  #
  #     Takes a string and appends it to the "activity" text property.
  #     Then attempts to save the order.
  #
  def update_activity(text)
    self.activity ||= ""
    length = self.activity.length
    unless self.activity.blank? || [10,13].include?(self.activity[length - 1])
      self.activity += "\n"
    end
    self.activity += text.strip
    return self.save
  end

  def received?
    # 6 = partially received
    # 7 = fully received
    self.status_id == PoStatus.partially_received_id || self.status_id == PoStatus.fully_received_id
  end

  def update_from(request, items)
    requested_line_items = RequestedLineItem.find(items)
    requested_line_items = requested_line_items.sort { |a, b| a.item_no <=> b.item_no }
    requested_line_items.each do |req_line|
      # If an ordered line item already exists for it, don't add it
      #this condition already exists because it's the req_line.items we're looking at:   requested_line_item_id = #{req_line.id}
      ordered_items_for_this_po = req_line.ordered_line_items.find_all_by_po_id(self.id)
      if ordered_items_for_this_po.size > 0
        #These items already exist for this po and this requested_line_item, for example, trying to add a second link to an existing item
        ordered_items_for_this_po.each do |line|
          line.order = self
          line.save
        end

      else # otherwise build a whole new one
        line = self.ordered_line_items.build
        line.description = req_line.material_description
        line.quantity_ordered = req_line.quantity
        line.notes = req_line.notes
        line.unit_of_measure = req_line.unit_of_measure
        line.requested_line_item_id = req_line.id
        line.save
      end
    end

    self.reload

    # set order columns if they're not already set
    if self.ptm_no.blank? || self.work_orders.blank? || self.deliver_to.blank?
      self.ptm_no = request.ptm_no if self.ptm_no.blank?
      self.work_orders = request.work_orders if self.work_orders.blank?
      self.deliver_to = request.deliver_to if self.deliver_to.blank?
      self.save
    end

    # only link order if it's not already linked
    unless request.order_ids.include?(self.id)
      self.material_requests << request
      # either append the tracking if one already exists, or set the tracking if it doesn't exist
      if self.tracking && !self.tracking.include?(request.tracking)
        self.tracking += ", #{request.tracking}"
      else
        self.tracking = request.tracking
      end
      self.save
    end
    return self
  end

  def self.create_from(req, items, po_no="")
    order = Order.new
    order.tracking = req.tracking
    order.unit_id = req.unit_id
    order.turnaround_year = req.year
    order.planner_id = req.planner_id
    order.deliver_to = req.deliver_to
    if(!req.stage_location.blank?)
      order.deliver_to +=  " (" + req.stage_location + ")"
    end



    order.ptm_no = req.ptm_no
    order.date_need_by = req.date_need_by
    order.work_orders = req.work_orders
    order.status_id = 5 # ordered
    if !po_no.blank?
      order.po_no = po_no
    end
    req_vendor = Vendor.find_by_name(req.suggested_vendor)
    order.vendor_id = req_vendor ? req_vendor.id : nil

    order.description = [req.unit_description + " " + req.year, req.deliver_to, req.work_orders, req.ptm_no, req.tracking, order.first_line_desc].delete_if { |i| i.blank? }.join(', ')
    order.save

    requested_line_items = RequestedLineItem.find(items)
    requested_line_items = requested_line_items.sort { |a, b| a.item_no <=> b.item_no }
    requested_line_items.each do |req_line|
      ordered_items_for_this_po = req_line.ordered_line_items.find_all_by_po_id(self.id)
      if !ordered_items_for_this_po.nil? && ordered_items_for_this_po.size > 0
        ordered_items_for_this_po.each do |line|
          line.order = order
          line.save
        end
      else
        line = order.ordered_line_items.build
        line.description = req_line.material_description
        line.quantity_ordered = req_line.quantity
        line.notes = req_line.notes
        line.unit_of_measure = req_line.unit_of_measure
        line.requested_line_item_id = req_line.id
        line.save
      end
    end

    req.orders << order
    return order
  end

  def self.ids_for_pos(pos)
    pos = pos.gsub(',', ' ')
    pos = pos.split(' ')
    orders = []
    pos.each do |po|
      results = Order.find(:all, :conditions => ['po_no LIKE ?', '%' + po + '%'])
      orders = orders + results if results.size > 0
    end
    return orders.map { |o| o.id }
  end

  def self.filter(params, employee)
    vendor = params[:vendor]
    unit = params[:unit]
    status = params[:status]
    location = params[:location]
    state = params[:state]
    year = params[:year]
    group = params[:group]

    string = "1 = 1"
    string += " AND vendor_id = ?" if !vendor.blank?
    string += " AND unit_id = ?" if !unit.blank?
    string += " AND status_id = ?" if !status.blank?
    string += " AND location = ?" if !location.blank?
    string += " AND group_id = ?" if !group.blank?

    string += " AND turnaround_year = ?" if !year.blank?
    conditions = [string]
    if !state.blank?
      if state == "open"
        conditions[0] += " AND closed != ? AND completed != ?"
        conditions.push(true)
        conditions.push(true)
      elsif state == "completed"
        conditions[0] += " AND closed != ? AND completed = ?"
        conditions.push(true)
        conditions.push(true)
      elsif state == "archived"
        conditions[0] += " AND archived = true"
      else # closed
        conditions[0] += " AND archived = false AND closed = ?"
        conditions.push(true)
      end
    end


    conditions.push(vendor) if !vendor.blank?
    conditions.push(unit) if !unit.blank?
    conditions.push(status) if !status.blank?
    conditions.push(location) if !location.blank?
    #conditions.push(true) if !state.blank?
    #conditions.push(true) if !state.blank?
    conditions.push(year) if !year.blank?
    conditions.push(group) if !group.blank?

    self.with_scope(:find => { :conditions => conditions }) do
      yield
    end
  end

  def request
    self.material_requests[0]
  end

  def first_line_desc
    if ordered_line_items[0]
      return ordered_line_items[0].description || ''
    else
      return ''
    end
  end

  def set_status_as_received
    unless PoStatus.any_received_ids.include?(self.status_id)
      self.status_id = PoStatus.partially_received_id
      self.save
    end
  end

  def requestor_name
    requester ? requester.full_name : ""
  end

  def planner_name
    planner ? planner.full_name : ""
  end

  def self.pos_received_today
    line_items = OrderedLineItem.find(:all, :conditions => [ "date_received = ?", Date.today ], :include => :order)
    line_items.map(&:order).uniq
  end

  def self.pos_received_this_week
    pos_received_from(7.days.ago.to_s(:db))
  end

  def self.pos_received_this_month
    pos_received_from(1.month.ago.to_s(:db))
  end

  def issued_to_date
    Date.today.to_s(:db)
  end

  def back_ordered_line_items
    self.ordered_line_items.find(:all).delete_if { |item| item.date_back_ordered.blank? }
  end

  def received_line_items
    self.ordered_line_items.find(:all).delete_if { |item| item.date_received.blank? }
  end

  def unreceived_line_items
    self.ordered_line_items.find(:all).delete_if { |item| !item.date_received.blank? }
  end

  def unissued_line_items
    self.ordered_line_items.find(:all).delete_if { |item| !item.issued_date.blank? }
  end

  def mark_remaining_as_received(date = Date.today)
    self.unreceived_line_items.each do |item|
      item.mark_as_received(date)
      item.save!
    end
  end

  def mark_remaining_as_issued(issued_to_name, issued_to_company, date)
    messages = []
    self.unissued_line_items.each do |item|
      unless item.issueable?
        messages << item.line_item_no
      end
    end
    if messages.blank?
      self.unissued_line_items.each do |item|
        item.mark_as_issued(issued_to_name, issued_to_company, date)
        item.save!
      end
    end
    return messages
  end

  def get_next_ordered_line_item_no
    item = self.ordered_line_items[0]
    if item.blank?
      return 1
    else
      item.last_position_in_list + 1
    end
  end



  def search_terms
    all_terms = ""
    [tracking, po_no, supplier, description, issued_to_history, unit_name, ptm_no, location, work_orders].each do |term|
      all_terms += ((term || "") + " ")
    end
    return all_terms
  end

  def show_description
    self.description.blank? ? "No Description" : self.description
  end

  def status_description
    self.status ? status.status : "Unspecified"
  end

  # Will be in the format W12345
  def self.newest_tracking
    MaterialRequest.newest_tracking
  end

  def supplier
    self.vendor ? vendor.name : ""
  end

  def supplier_contact
    self.vendor ? self.vendor.contact_name : ""
  end

  def supplier_phone
    self.vendor ? self.vendor.telephone : ""
  end

  def supplier_no
    self.vendor ? self.vendor.vendor_no : ""
  end

  def unit_description
    self.unit ? self.unit.description : ""
  end

  def unit_name
    self.unit ? self.unit.description : ""
  end

  def unit_description=(description)
    unit = Unit.find_by_description(description)
    if unit
      self.unit_id = unit.id
    end
  end

  #
  def show_location
    if !self.location.blank?
      return self.location
    elsif !self.ordered_line_items.blank?
      locations_array = []
      self.ordered_line_items.each {|li| locations_array << li.location if !li.location.blank?}
      locations = locations_array.join(', ')
      return locations.blank? ? "No Location" : locations
    else
      return "No Location"
    end
  end

  def show_issued_to_history
    issued_to_history.blank? ? "No History" : self.issued_to_history.gsub("\n", "<br />")
  end

  # We have to override the searchable to take into account the 'year' condition
  def self.search_with_year(params = {}, options = {})
    conditions = {}
    unless params[:year].blank?
      conditions = { :find => { :conditions => [ "purchase_orders.turnaround_year = ?", params[:year] ] }}
    end

    options.merge!(:include => [:vendor, :unit, :status])

    with_scope(conditions) do
      @orders = Order.full_text_search(params, options)
    end

    return @orders
  end

  def create_or_update_line_item(item_no, item_attributes)
    return if all_blank?(item_attributes)
    line_item = self.ordered_line_items.find_by_line_item_no(item_no) || self.ordered_line_items.build
    line_item.attributes = item_attributes
    line_item.save!
  end

  def self.all_turnaround_years
    @@all_turnaround_years ||= self.find_by_sql("SELECT distinct(turnaround_year) FROM purchase_orders ORDER BY turnaround_year;").collect do |order|
      next if order.turnaround_year !~ /\d\d\d\d/
      next if order.turnaround_year.blank?
      order.turnaround_year
    end
  end

  def self.all_locations
    Order.find(:all, :select => "distinct(location)", :order => "location").delete_if { |order| order.location.blank? }.map { |order| order.location }
  end

  def self.all_units
    orders = Order.find(:all,
                        :select => "unit_id",
                        :group => "unit_id",
                        :conditions => ['purchase_orders.unit_id IS NOT NULL']
    )
    unit_ids = orders.map {|o| o.unit_id }
    units = Unit.find(unit_ids, :order => 'description')
  end

  def self.all_vendors
    orders = Order.find(:all,
                        :select => "vendor_id",
                        :group => "vendor_id",
                        :conditions => ['purchase_orders.vendor_id IS NOT NULL']
    )
    vendor_ids = orders.map {|o| o.vendor_id }
    vendors = Vendor.find(vendor_ids, :order => 'name')
  end

  def self.all_statuses
    PoStatus.list_status
  end

  def year_selection
    if self.new_record?
      (Time.now.year..(Time.now.year + 4)).map do |y|
        [y.to_s,y.to_s]
      end
    else
      early_year = self.turnaround_year.to_i - 2
      (early_year..(Time.now.year + 4)).map do |y|
        [y.to_s,y.to_s]
      end
      # return Order.all_turnaround_years.map { |year| [year, year] }
    end
  end

  def format_description
    if self.description
      self.description = self.description.gsub(/,([^\s])/, ', \1')
    end
  end

  def format_description!
    self.format_description
  end

  def get_group
    if self.group
      default_group = self.group
    else
      default_group = Group.get_default
    end
    return default_group ? default_group['id'] : nil
  end

  # ===============
  # = CSV support =
  # ===============
  comma do
    Order.column_names.each do |column_name|
      case column_name
        when 'delta'
          #skip
        when 'unit_id'
          unit 'Unit Description' do |u| u.try(:description)  end
        when 'vendor_id'
          vendor 'Vendor Name' do |v| v.try(:name) end
        when 'status_id'
          status 'Status' do |s| s.try(:status) end
        when 'planner_id'
          planner 'Planner First name' do |p| p.try(:first_name) end
        when 'requested_by_id'
          requester 'Requested by First name' do |r| r.try(:first_name) end
        when 'group_id'
          group 'Group Name' do |g| g.try(:name) end
        else
          send(column_name)
      end
    end
  end


  ##############################################################################
  private

  def all_blank?(hash)
    hash.each do |key, value|
      if !value.blank?
        return false
      end
    end

    return true
  end

  def self.pos_received_from(date)
    line_items = OrderedLineItem.find(:all, :conditions => { :date_received => date..Date.today.to_s(:db) }, :include => :order )
    line_items.map(&:order).uniq
  end

  def set_status
    if self.closed?
      self.completed = true
    end

    if self.completed?
      @status_set_to_fully_received = true if self.status_id != PoStatus.fully_received_id
      self.status_id = PoStatus.fully_received_id
    end
  end

  def create_event
    self.events.create(:description => "created new purchase order ##{self.po_no}")
  end

  def update_event
    if !Event.recent_for?(self)
      self.events.create(:description => "updated purchase order ##{self.po_no}")
    end
  end

  def update_reminders_if_eta_has_changed
    if self.eta_change_difference
      upcoming_reminders = self.find_upcoming_reminders
      upcoming_reminders.each do |reminder|
        reminder.send_reminder_on -= self.eta_change_difference
        reminder.save
      end
      self.eta_change_difference = nil
    end
  end
end
