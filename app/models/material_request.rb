# == Schema Information
# Schema version: 20090730175917
#
# Table name: material_requests
#
#  id                      :integer(4)    not null, primary key
#  tracking                :string(255)   
#  unit_id                 :integer(4)    
#  planner_id              :integer(4)    
#  year                    :string(255)   
#  requested_by_id         :integer(4)    
#  date_requested          :datetime      
#  telephone               :string(255)   
#  date_need_by            :date          
#  work_orders             :string(255)   
#  deliver_to              :string(255)   
#  ptm_no                  :string(255)   
#  suggested_vendor        :string(255)   
#  notes                   :text          
#  authorized_by           :integer(4)    
#  acknowledged_by         :integer(4)    
#  purchaser_id            :integer(4)    
#  stage_location          :string(255)   
#  drafted_by              :integer(4)    
#  request_state           :integer(4)    default(0)
#  submitted_by            :integer(4)    
#  quote_requested_by      :integer(4)    
#  partially_authorized_by :integer(4)    
#  declined_by             :integer(4)    
#  completed               :boolean(1)    
#  updated_at              :datetime      
#  created_by              :integer(4)    
#  issued_from_main_by     :integer(4)    
#  activity                :text          
#  deleted                 :boolean(1)    
#  surplus                 :boolean(1)    
#  created_at              :datetime      
#  updated_by              :integer(4)    
#  tracking_number_type    :string(255)   
#  tracking_number         :string(255)   
#

class MaterialRequest < ActiveRecord::Base
  extend Listable::ModelHelper

  PERPAGE = 50

  attr_accessor :new_order_po, :current_employee_id

  DEFAULT_REFERENCE_NUMBER_TYPE = 'Process/Ticket/MES'

  belongs_to :unit
  belongs_to :planner, :class_name => "Employee", :foreign_key => "planner_id"
  belongs_to :requester, :class_name => "Employee", :foreign_key => "requested_by_id"
  belongs_to :purchaser, :class_name => "Employee", :foreign_key => "purchaser_id"
  belongs_to :drafter, :class_name => "Employee", :foreign_key => "drafted_by"

  has_one :bill
  has_many :items, :class_name => "RequestedLineItem", :foreign_key => "material_request_id", :order => "requested_line_items.item_no", :dependent => :destroy
  has_many :quotes, :dependent => :destroy
  has_many :events, :as => :recordable, :dependent => :destroy
  has_and_belongs_to_many :orders
  belongs_to :group

  has_many :material_request_attachments, :dependent => :destroy

  #THIS IS GOING TO BE DEPRECATED.  JUST BEING USED FOR THE MIGRATIONS FOR NOW.
  has_attached_file :attachment, :path => ":rails_root/data/material_request/request_attachment_:id.:extension"
  def attached_file_path
    file_extension = self.attachment_file_name[self.attachment_file_name.rindex('.')..self.attachment_file_name.length]
    "#{Rails.root}/data/material_request/request_attachment_#{self.id}#{file_extension}"
  end

  # Thinking Sphinx Config
  define_index do
    # Columns
    #indexes content
    indexes :tracking
    #	indexes :ptm_no
    indexes reference_number_type
    indexes reference_number
    indexes :notes
    indexes :deliver_to
    indexes :suggested_vendor
    # Associations
    indexes items(:material_description), :as => :line_item_descriptions
    indexes unit(:description), :as => :unit_description
    indexes [requester(:first_name), requester(:mi), requester(:last_name)], :as => :requester_name
    set_property :delta => :datetime,
                 :threshold => 1.minute,
                 :delta_column => :updated_at
  end

  validates :tracking, :unit_id, :requested_by_id, :presence => true
  validates :tracking, :uniqueness => true
  validates :year, :numericality => { :message => "is not a valid year" }
  validates :description, :presence => true


  before_validation :set_tracking,  :on => :create
  before_validation :set_acknowledged_and_authorized

  before_create :current_employee_b_create
  before_save :current_employee_b_save

  def current_employee_b_create
    # Set the created_by field
    self.created_by = self.current_employee_id || self.requested_by_id
  end

  def current_employee_b_save
    self.updated_by = self.current_employee_id || Employee.current_employee_id
    # If request is no longer a draft, fill in date_requested
    self.date_requested ||= Time.now unless self.is_draft?
  end

  after_create :create_event
  after_update :update_event


  def uploaded_material_request_attachments=(array_of_files)
    unless array_of_files.blank?
      array_of_files.each do |file|
        self.material_request_attachments.create!(:attachment => file) unless file.blank?
      end
    end
  end

  def uploaded_material_request_attachment=(data)
    unless data.blank?
      self.material_request_attachments.create!(:attachment => data)
    end
  end

  def items_sorted
    self.items.sort do |x, y|
      if x.item_no == y.item_no
        0
      elsif x.item_no == nil
        -1
      elsif y.item_no == nil
        1
      else
        x.item_no <=> y.item_no
      end
    end
  end

  # states_for :request_state => ["Manual Request", "Web Request", "Out For Quote", "PO Issued"]
  def self.track_author(*fields)
    fields.each do |field|
      field = field.to_s

      define_method(field) do
        # Returns 0 or 1 for checkboxes
        return self.send(field + "_by").blank? ? 0 : 1
      end

      define_method(field + "?") do
        return !self.send(field + "_by").blank?
      end

      define_method(field + "=") do |value|
        if value.to_s == "1" && self.send(field + "_by").blank?
          self.send(field + "_by=", self.current_employee_id)
        elsif value.to_s != "1"
          self.send(field + "_by=", nil)
        end
      end

      define_method('show_' + field + '_by') do
        if self.send(field + '_by').blank?
          ''
        else
          employee = Employee.find_by_id(self.send(field + '_by'))
          employee ? employee.short_name : ''
        end
      end
    end
  end

  def assignable?
    return self.acknowledged? && (self.partially_authorized? || self.authorized?)
  end

  track_author :drafted,
               :submitted,
               :acknowledged,
               :quote_requested,
               :partially_authorized,
               :authorized,
               :declined,
               :issued_from_main

  validates_associated :unit
  validates_associated :planner
  validates_associated :requester

  def initialize(attributes = nil, options = {})
    super
    if self.new_record?
      self.date_need_by ||= 3.days.from_now.to_date
      self.year ||= Date.today.year
    end
    self.group_id ||= Group.get_default_id
    self.reference_number_type ||= ReferenceNumberType.get_default_type
  end

  def requester_name(with_id=false)
    if requester && with_id
      return requester.entire_name_with_id
    elsif requester
      return requester.entire_full_name
    else
      return ""
    end
  end

  def authorized_by_name
    if self.authorized_by
      "Authorized by " + Employee.find(self.authorized_by).full_name
    else
      ""
    end
  end

  def get_json
    if self.purchaser_id.blank?
      [self.id, self.tracking, "#{self.requester.entire_full_name}, #{self.unit.description},  Unspecified Purchaser"].to_json
    else
      [self.id, self.tracking, "#{self.requester.entire_full_name}, #{self.unit.description},  #{self.purchaser.entire_full_name}"].to_json
    end
  end

  def self.list_years
    this_year = Date.today.year
    result = ((this_year - 1)..(this_year+3)).map { |year| [year.to_s, year.to_s] }
  end

  def acknowledged_by_name
    if self.acknowledged_by
      "Acknowledged by " + Employee.find(self.acknowledged_by).full_name
    else
      ""
    end
  end

  def self.requests_for_planner(planner_id)
    MaterialRequest.find(:all, :conditions => ["planner_id = ? AND date_requested = ?",
                                               planner_id, Date.today.to_s(:db)])
  end

  def item_count
    self.items.size
  end

  def unit_name
    self.unit.description
  end

  def unit_name=(description)
    unit = Unit.find_by_description(description.strip)
    if unit
      self.unit_id = unit.id
    end
  end

  def build_with_items(req, lines)
    self.attributes = req
    if lines.blank?
      return self
    end

    lines = lines.sort { |a,b| a[0].to_i <=> b[0].to_i }
    lines.each do |item_id, attrs|
      item = self.items.find_by_id(item_id) || self.items.build
      item.attributes = attrs
      item.material_description = attrs[:material_description]
    end

    self.items.each_with_index { |item, index| item.id ||= index + 1; item.item_no ||= index + 1 }

    return self
  end


  def update_with_new_items(lines)
    lines.each do |line_attr|
      item = self.items.build(:material_request_id => self.id)
      item.attributes = line_attr
      item.save
    end
    return self
  end

  def update_with_items(req, lines)
    self.attributes = req
    if self.group_id.nil?
      current_employee = Employee.find(self.current_employee_id)
      self.group_id = current_employee.get_group
    end
    self.save!
    if lines.blank?
      return self
    end
    lines = lines.sort { |a,b| a[0].to_i <=> b[0].to_i }
    lines.each do |item_id, attrs|
      item = items.find_by_id(item_id) || self.items.build(:material_request_id => self.id)
      item.attributes = attrs
      item.save
    end
    return self
  end

  def self.last_request_for_employee(employee_id)
    MaterialRequest.find(:first, :conditions => { :requested_by_id => employee_id }, :order => "id DESC")
  end

  def status
    if self.completed?
      "Ordered"
    elsif self.declined?
      span_color("Declined", 'red')
    elsif self.authorized?
      "Fully Authorized"
    elsif self.partially_authorized?
      "Partially Authorized"
    elsif self.quote_requested?
      "Out for Quote"
    elsif self.acknowledged?
      "Acknowledged"
    elsif self.is_draft?
      span_color('Draft', '#999')
    else
      span_color('Submitted (New)', 'green', true)
    end
  end

  def is_draft?
    return self.drafted? && !self.acknowledged?
  end

  def self.options_for_index(employee)
    options = [['all', 'All Requests'],
               ['mine', 'Mine (Requested By Me)'],
               ['created_me', 'Created By Me'],
               ['drafts', 'My Drafts Only'],
               ['submitted', 'Submitted'],
               ['process_acknowledged', 'In Process (Acknowledged)'],
               ['process_out_for_quote', 'In Process (Out For Quote)'],
               ['authorized', 'Authorized'],
               ['declined', 'Declined'],
               ['completed', 'Ordered']]
    if employee.need_details?
      options.insert(1, ["all_drafts", "All Drafts"])
    end
    return options
  end

  def self.search(params={},options={})
    with_scope(:find => {:conditions => ["material_requests.deleted = ?", false] }) do
      full_text_search(params,options)
    end
  end

  def span_color(term, color, bold = false)
    html = ""
    html += "<b>" if bold
    html += "<span style='color: #{color}'>#{term}</span>"
    html += "</b>" if bold
    return html
  end

  def self.for_employee(employee, params, status = nil)
    # Set the scope conditions if needed        
    conditions = case status
                   when "mine"
                     ["requested_by_id = ?", employee.id]
                   when "all"
                     ["1 = 1"]
                   when "all_drafts"
                     ["drafted_by IS NOT NULL AND submitted_by IS NULL and acknowledged_by IS NULL AND authorized_by IS NULL"]
                   when "drafts"
                     ["drafted_by = ? AND submitted_by IS NULL AND acknowledged_by IS NULL AND authorized_by IS NULL", employee.id]
                   when "submitted"
                     ["submitted_by IS NOT NULL AND acknowledged_by IS NULL AND drafted_by IS NULL"]
                   when "process_acknowledged"
                     ["acknowledged_by IS NOT NULL AND quote_requested_by IS NULL AND authorized_by IS NULL AND declined_by IS NULL"]
                   when "process_out_for_quote"
                     ["quote_requested_by IS NOT NULL AND authorized_by IS NULL"]
                   when "authorized"
                     ["authorized_by IS NOT NULL AND completed = ?", false]
                   when "declined"
                     ["declined_by IS NOT NULL AND completed = ?", false]
                   when "completed"
                     ["completed = ?", true]
                   when "created_me"
                     ["created_by = ? OR drafted_by = ?", employee.id, employee.id]
                   else # default is all
                     ["1 = 1"]
                 end

#    if params[:group].blank?
#    	params[:group] = employee.get_group
#   	end

    self.filter(params) do
      with_scope(:find => { :conditions => ["material_requests.deleted = ?", false] }) do
        with_scope(:find => { :conditions => conditions }) do
          self.list(params, :include => [:requester, :unit, :items], :order => "material_requests.id", :sort => "DESC")
        end
      end
    end
  end

  def self.all_units
    unit_ids = MaterialRequest.find(:all, :select => "distinct(unit_id)").map(&:unit_id)
    Unit.find(unit_ids, :order => "description")
  end

  def self.all_requesters
    requester_ids = MaterialRequest.find(:all, :select => "distinct(requested_by_id)").map(&:requested_by_id)
    Employee.find(requester_ids, :order => "last_name", :select => "id, first_name, last_name, mi")
  end

  def self.get_scope(params)
    if params[:unit] && params[:requester]
      return ['material_requests.unit_id = ? AND material_requests.requested_by_id = ?', params[:unit], params[:requester]]
    elsif params[:unit]
      return ['material_requests.unit_id = ?', params[:unit]]
    elsif params[:requester]
      return ['material_requests.requested_by_id = ?', params[:requester]]
    else
      return '1 = 1'
    end
  end

  def self.newest_tracking
    req = MaterialRequest.find(:first, :order => "tracking DESC", :conditions => "tracking like 'W_____'") || MaterialRequest.new(:tracking => "W00000")
    order = Order.find(:first, :order => "tracking DESC", :conditions => "tracking like 'W_____'") || Order.new(:tracking => "W00000")

    number = extract_number(req, order)

    tracking = number.to_s
    size = tracking.length
    (5 - size).times do
      tracking = "0" + tracking
    end

    return "W" + tracking
  end

  def authorized?
    authorized_by
  end

  def orders_with_new
    self.orders.unshift(Order.new(:po_no => "New Order"))
  end

  def unit_description
    self.unit ? self.unit.description : ""
  end

  def line_item_descriptions
    items.map(&:material_description).join(" ")
  end

  def disabled_for?(employee)
    self.acknowledged_by != nil && !employee.admin? && !employee.purchasing?
  end

  def created_by_name
    Employee.find(self.created_by).short_name
  end

  def delete_default_items!
    self.items.each do |requested_line_item|
      if requested_line_item.material_description == "Enter Description"
        requested_line_item.destroy
      end
    end
  end


  def self.filter(params)
    unit = params[:unit]
    requester = params[:requester]
    group = params[:group]

    string = "1 = 1"
    string += " AND unit_id = ?" if !unit.blank?
    string += " AND requested_by_id = ?" if !requester.blank?
    string += " AND material_requests.group_id = ?" if !group.blank?

    conditions = [string]
    conditions.push(unit) if !unit.blank?
    conditions.push(requester) if !requester.blank?
    conditions.push(group) if !group.blank?

    self.with_scope(:find => { :conditions => conditions }) do
      yield
    end
  end

  def get_group
    if self.group
      default_group = self.group
    else
      default_group = Group.get_default
    end
    return default_group ? default_group['id'] : nil
  end

  def get_reference_number_type
    self.reference_number_type.present? ? self.reference_number_type : DEFAULT_REFERENCE_NUMBER_TYPE
  end


# ===============
# = CSV support =
# ===============
  comma do
    MaterialRequest.column_names.each do |column_name|
      case column_name
        when 'delta'
          #skip
        when 'unit_id'
          unit 'Unit Description' do |u| u.try(:description)  end
        when 'planner_id'
          planner 'Planner First name' do |p| p.try(:first_name) end
        when 'requested_by_id'
          requester 'Requested by First name' do |r| r.try(:first_name) end
        when 'purchaser_id'
          purchaser 'Purchaser First name' do |p| p.try(:first_name) end
        when 'drafted_by'
          drafter 'Drafted by First name' do |d| d.try(:first_name) end
        when 'group_id'
          group 'Group Name' do |g| g.try(:name) end
        else
          send(column_name)
      end
    end
  end




  ##############################################################################
  private

  def set_tracking
    if self.tracking.blank?
      self.tracking = MaterialRequest.newest_tracking
    end
  end

  def self.extract_number(req, order)
    req.tracking =~ /(\d+)$/
    number_1 = $1.to_i + 1

    order.tracking =~ /(\d+)$/
    number_2 = $1.to_i + 1

    if(number_1 > number_2)
      return number_1
    else
      return number_2
    end
  end

  def set_acknowledged_and_authorized
    if self.acknowledged_by == nil && (self.authorized_by? || self.declined?)
      self.acknowledged_by ||= self.current_employee_id
    end
  end

  def create_event
    self.events.create(:description => "created new material request ##{self.tracking}")
  end

  def update_event
    if !Event.recent_for?(self)
      self.events.create(:description => "updated material request ##{self.tracking}")
    end
  end
end
