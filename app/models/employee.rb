# == Schema Information
# Schema version: 20090730175917
#
# Table name: employees
#
#  id                        :integer(4)    not null, primary key
#  badge_no                  :integer(4)
#  last_name                 :string(255)
#  first_name                :string(255)
#  mi                        :string(255)
#  login                     :string(255)
#  company_id                :integer(4)
#  email                     :string(255)
#  telephone                 :string(255)
#  lock_version              :integer(4)    default(0)
#  updated_at                :datetime
#  role                      :integer(4)    default(1)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  start_page                :integer(4)    default(1)
#  seen_updates              :boolean(1)    default(TRUE)
#  direct_search             :boolean(1)
#  fax                       :string(255)
#  buyer                     :boolean(1)
#  archived                  :boolean(1)
#  current_bom_id            :integer(4)
#  current_popv_tabs         :text
#  popv_enabled              :boolean(1)
#

# Roles are done by assigning an integer value, which are specified in the
# "states_for :roles" statement below. Ex: POPV_VIEWER is role #13.

require 'digest/sha1'

class Employee < ActiveRecord::Base
  # Using ThinkingSphinx now... (Adam - 2009-06-18)
  # acts_as_ferret :fields => [:badge_no, :last_name, :first_name, :mi, :login, :email, :telephone]



  #states_for :role => [ "Admin", "Warehouse", "Purchasing", "Planning", "Requesting", "Warehouse Admin", "Vendor",
  # "Receiving", "Foreman", "Engineer", "Estimator", "Requesting Admin", "POPV Admin", "POPV Viewer"]
  states_for :start_page => ['Menu', 'Orders', 'Material Requests', 'Web Requests', 'Reports', 'POPV']
  #validates_inclusion_of_role :message => "must be one of admin, warehouse, purchasing, planning, or requesting", :allow_nil => true


  ADMIN = 0
  WAREHOUSE = 1
  PURCHASING=2
  PLANNING=3
  REQUESTING=4
  WAREHOUSE_ADMIN=5
  VENDOR=6
  RECEIVING = 7
  FOREMAN=8
  ENGINEER=9
  ESTIMATOR=10
  REQUESTING_ADMIN=11
  POPV_ADMIN=12
  POPV_VIEWER=13

  ROLE_NAMES=[ "Admin", "Warehouse", "Purchasing", "Planning", "Requesting", "Warehouse Admin", "Vendor",
               "Receiving", "Foreman", "Engineer", "Estimator", "Requesting Admin", "POPV Admin", "POPV Viewer"]

  def state_for_role
    return ROLE_NAMES[self.role]
  end
  def admin?
    self.role == Employee::ADMIN
  end
  def warehouse?
    self.role == Employee::WAREHOUSE
  end
  def purchasing?
    self.role == Employee::PURCHASING
  end

  def planning?
    self.role == Employee::PLANNING
  end
  def requesting?
    self.role == Employee::REQUESTING
  end
  def warehouse_admin?
    self.role == Employee::WAREHOUSE_ADMIN
  end
  def vendor?
    self.role == Employee::VENDOR
  end
  def receiving?
    self.role == Employee::RECEIVING
  end
  def foreman?
    self.role == Employee::FOREMAN
  end
  def engineer?
    self.role == Employee::ENGINEER
  end
  def estimator?
    self.role == Employee::ESTIMATOR
  end
  def requesting_admin?
    self.role == Employee::REQUESTING_ADMIN
  end
  def popv_admin?
    self.role == Employee::POPV_ADMIN
  end
  def popv_viewer?

    self.role == Employee::POPV_VIEWER
  end

  acts_as_log_edits

  extend Listable::ModelHelper

  belongs_to :company, :class_name => "Company", :foreign_key => "company_id"

  has_many :bills
  has_many :carts
  has_many :planned_orders, :class_name => "Order", :foreign_key => "planner_id"
  has_many :requested_orders, :class_name => "Order", :foreign_key => "requested_by_id"
  has_many :material_requests, :foreign_key => "requested_by_id"

  has_one :basket

  belongs_to :current_bom, :class_name => "Bill", :foreign_key => 'current_bom_id'
  belongs_to :group

  # Thinking Sphinx Config
  define_index do
    indexes :badge_no
    indexes :first_name
    indexes :mi
    indexes :last_name
    indexes :login
    indexes :email
    indexes :telephone

    set_property :delta => true
  end

  attr_accessor :password_confirmation, :password
  attr_writer :page
  cattr_accessor :current_employee
  SEXT_INCLUDE = [:company ]
  PERPAGE = 100


  validates_presence_of :first_name, :last_name
  validates_presence_of :company_id
  validates_numericality_of :badge_no, :only_integer => true, :allow_nil => true

  validates_uniqueness_of :login, :case_sensitive => false, :if => Proc.new { |e| !e.login.blank? }
  validates_confirmation_of :password

  before_validation :verify_popv_open_user
  before_save :encrypt_password
  before_create :set_start_page

  # Prevents anyone from changing the role of the 'popv' user, thereby allowing
  # anyone with the user and login for this user to access other resources
  # that are specifically restricted to this public account.
  def verify_popv_open_user
    if !self.new_record? && self.id
      employee = Employee.find_by_id(self.id)
    else
      employee = self
    end

    if employee.login == 'popv'
      self.login = 'popv'
      self.first_name = 'POPV'
      self.last_name = 'POPV'
      self.role = Employee::POPV_VIEWER
      self.popv_enabled = false
      self.buyer = false
      self.archived = false
      self.start_page = POPV
      self.remember_token_expires_at = nil
      self.remember_token = nil
      c = Company.find_by_name('Telaeris')
      if c.present?
        self.company = c
      end
    end
  end

  # TODO: what was this for again?  some views macro?
  def page
    @page || 1
  end

  # is the role value even valid?
  def invalid_role?
    self.role.blank? || self.role < 0
  end

  # Warehouse role should be the default and Warehouse Admins should be considered warehouse users
  def warehouse?(exclude_admin = false)
    invalid_role = self.invalid_role?
    is_warehouse = self.role == Employee::WAREHOUSE
    is_admin_and_valid = !exclude_admin && self.warehouse_admin?  # can we inlude warehouse_admins?
    return is_warehouse || is_admin_and_valid || invalid_role
  end

  # Both requester and requester admin should be considered requesters
  def requesting?(exclude_admin = false)
    return self.role == Employee::REQUESTING || (!exclude_admin && self.requesting_admin?)
  end

  # Both purchasing and planning should be considered purchasing
  def purchasing?(exclude_planning = false)
    return self.role == Employee::PURCHASING || (!exclude_planning && self.role == Employee::PLANNING)
  end

  # Both planning and purchasing should be considered planning
  def planning?(exclude_purchasing = false)
    return self.role == Employee::PLANNING || (!exclude_purchasing && self.role == Employee::PURCHASING)
  end

  # An employee needs details if he/she is an admin or part of the purchasing
  def need_details?
    admin? || purchasing? || popv_admin?
  end

  def admin?
    return (self.role == Employee::ADMIN || self.role == Employee::POPV_ADMIN)
  end

  def popv_user?
    self.popv_enabled || popv_admin?
  end


  def can_view_popv?
    return popv_viewer? || popv_user?
  end

  def self.current_employee_id
    self.current_employee ?	self.current_employee.id : nil
  end

  def self.current_employee_name
    self.current_employee ?	self.current_employee.entire_full_name : ''
  end

  def self.find_or_create_popv_viewer
    user = self.find_by_login('popv')
    if user.blank?
      user = self.create(:login => 'popv')
    end
    return user
  end

  # Returns an array for options in a select tag
  def self.options_for_role
    roles = [
        ['Admin', ADMIN],
        ['Warehouse', WAREHOUSE],
        ['Warehouse Admin', WAREHOUSE_ADMIN],
        ['Purchaser', PURCHASING],
        ['Planner', PLANNING],
        ['Requester', REQUESTING],
        ['Requester Admin', REQUESTING_ADMIN],
        ['Receiver', RECEIVING],
        ['Engineer', ENGINEER],
        ['POPV Viewer', POPV_VIEWER]
    ]

    if(Rails.env.development? || Rails.env.test? || Employee.current_employee.popv_admin?)
      roles << ['POPV Admin', POPV_ADMIN]
    end

    return roles
  end

  # Should filter employees, only showing the employees with logins and passwords
  def self.list_users_only(*args)
    Employee.with_scope(:find => { :conditions => "login IS NOT NULL AND crypted_password is NOT NULL"}) { self.list(*args) }
  end

  # Should only scope within the scope of employees with a login and password
  def self.search_users_only(*args)
    Employee.with_scope(:find => { :conditions => "login IS NOT NULL AND crypted_password is NOT NULL"}) { self.full_text_search(*args) }
  end

  # Find all the companies to which at least one employee belongs to
  def self.all_companies
    company_ids = Employee.find(:all, :select => "distinct(company_id)").map(&:company_id)
    company_ids.delete(0)
    Company.find(company_ids, :order => "name")
  end

  # Finds all buyers
  def self.find_buyers
    find(:all, :conditions => {:buyer => true})
  end

  # Builds up an array of arrays with name/email pairs for use in a drop-down select box
  def self.buyer_list_of_emails_for_select_tag
    email_array = [["Buyer", "Buyer"], ["--", ""], ['All', '']]
    all_emails_array = []
    self.find_buyers.each {|b| email_array << [b.entire_full_name, b.email]; all_emails_array << b.email}
    email_array[2][1] = all_emails_array.join(', ') # Adds a string of all emails to the 'All' array.
    return email_array
  end

  # Retrieves the 'current cart' for an employee, which is effectively like Amazon's shopping cart
  # Every user has one and can add items to it
  # If no cart currently exists for that user, just create one
  def last_cart
    Cart.create(:employee_id => self.id) if self.carts.size == 0
    cart = self.carts.find(:first, :order => "id DESC")
    cart.requested_by_id ||= self.id
    cart.telephone = self.telephone
    return cart
  end

  # Returns the employee's name and email in the standard email format
  # Example:   Hugh Bien <hugh@telaeris.com>
  def name_and_email
    if email
      return "#{self.entire_full_name} <#{self.email}>"
    else
      return nil
    end
  end

  def self.create_telaeris_admin
    e = Employee.find_by_login("telaeris_admin")
    if(e.blank?)
      e = Employee.new
    end

    if(Company.count <= 0)

      c = Company.create(:name =>"Telaeris")
    else
      c = Company.first
    end
    e.company = c
    e.first_name = "Telaeris"
    e.last_name = "Admin"
    e.login = "telaeris_admin"
    e.password = "t3la3ris"
    e.password_confirmation = "t3la3ris"
    e.email = "support@telaeris.com"
    e.group = Group.first
    e.role = 'Admin'
    e.save!
  end

  # Filters the employee index by either company or role
  #   params[:company] = company_id, this will only list employees with this company
  #   params[:role] = Employee::WAREHOUSE, this will only list employees of Warehouse role
  # Example:
  #   # Find all warehouse employees with company_id = 1
  #   Employee.filter(:role => Employee::WAREHOUSE, :company => 1) do
  #     Emloyee.find(:all, :conditions => { ... })
  #   end
  def self.filter(params = {})
    conditions = "1 = 1"
    args = []
    if !params[:company].blank?
      conditions += " AND company_id = ?"
      args.push(params[:company])
    end
    if !params[:role].blank?
      conditions += " AND role = ?"
      args.push(params[:role])
    end
    if !params[:archived].blank?
      conditions += " AND archived = ?"
      if params[:archived] == 'true'
        args.push(true)
      else
        args.push(false)
      end
    end

    conditions = args.unshift(conditions)
    self.with_scope(:find => { :conditions => conditions }) do
      yield
    end
  end

  # builds an order based on what role this employee is
  def new_order(params = {})
    params =  { :created => Date.today, :turnaround_year => "2007" }.merge(params)
    if self.requesting?
      self.requested_orders.build({ :date_requested => Date.today.to_s(:db) }.merge(params))
    elsif self.planning?
      self.planned_orders.build(params)
    else
      Order.new(params)
    end
  end

  # Displays the appropriate name to views (Bien, Hugh)
  def full_name
    last_name.blank? ? "#{first_name} #{mi}" : "#{last_name}, #{first_name} #{mi}"
  end

  # Displays the abbreviated name of an employee (H. Bien)
  def short_name
    return "#{first_name[0].chr}. #{last_name}"
  end

  # Displays an employee's name in an informal format (Hugh Bien D)
  def entire_full_name
    mi.blank? ? "#{first_name} #{last_name}" : "#{first_name} #{mi} #{last_name}"
  end

  # Displays an employee's name and ID in parenthesis
  # Hugh D Bien (1)
  def entire_name_with_id
    self.entire_full_name + " (#{self.id})"
  end

  # Returns an array of employee and IDs for select_tags in the view
  # Valid options:
  #   :name => true or false, false by default
  #       If set to true, will use employee's short name (H. Bien) for the value instead of the employee's ID
  #   :default => String, nil by default
  #       list_employees appends a [nil, nil] to the beginning of all your  choices, this will show up
  #       as blank in <select> tags, to have it say something like "Default" you would use this option
  def self.list_employees(options = {})
    Employee.find(:all, :order => "last_name").map { |e| [e.full_name, (options[:name] ? e.short_name : e.id)] }.unshift([options[:default], nil])
  end

  # Method for autocompletes that will list out all employee names that are similar to the 'query' parameter
  # If use_id is set to true, the results will be returned like this ("Hugh Bien (id)")
  def self.list_employee_names(query, use_id=false)

    Employee.find(:all, :conditions => ["first_name LIKE ? OR last_name LIKE ?", '%' + query + '%', '%' + query + '%'],  :order => "last_name", :limit => 20).map do |e|
      use_id ? e.entire_name_with_id : e.entire_full_name
    end
  end

  # Shortcut for listing employee names with an ID
  def self.list_requester_names(query)
    list_employee_names(query, true)
  end

  # Shortcut for select_tag (list_employee_names), except only list out purchasers and admins
  def self.list_purchasers(options = {})
    with_scope(:find => {:conditions => ["role = ? OR role = ? OR role = ?", Employee::POPV_ADMIN, Employee::ADMIN, Employee::PURCHASING]}) do
      self.list_employees({:default => "Purchasing Department"}.merge(options))
    end
  end

  # Shortcut for select_tag (list_employee_names), except only list out planners
  # If passed an employee id, it will add that employee to the box, in case they
  # need to be there but aren't a planner.
  def self.list_planners(extra_employee_id = nil)
    planners = []
    with_scope(:find => { :conditions => ["role = ?", Employee::PLANNING]}) do
      planners = self.list_employees
    end
    if extra_employee_id
      extra_employee = Employee.find(extra_employee_id)
      if extra_employee.present?
        planners.push([extra_employee.full_name, extra_employee.id])
      else
        planners.push(["This Employee could not be found.", extra_employee.id])
      end
    end
    planners
  end

  # Shortcut for select_tag (list_employee_names), except only list out requesters
  def self.list_requestors(options = {})
    with_scope(:find => { :conditions => ["role = ? OR role = ?", Employee::REQUESTING, Employee::REQUESTING_ADMIN]}) do
      self.list_employees(options)
    end
  end

  # Shortcut for select_tag (list_employee_names), except only list out requesters
  def self.list_popv_admin_emails(options = {})
    Employee.find(:all, :conditions => ["role = ?", Employee::POPV_ADMIN], :order => "last_name", :limit => 20).map do |e|
      e.email
    end
  end

  # Determines if a user can create new employees
  def profile_admin?
    self.popv_admin? || self.admin? || self.warehouse_admin? || self.requesting_admin?
  end

  # Determines if a user is able to edit the login/passwords for another user
  def edit_login?(user)
    # Editable if the user is an admin OR
    # the user is editing his own settings
    edit_profile?(user) || self == user
  end

  # Determines if a user is able to edit the profile for another user
  # Settings include roles, badge no, email, etc...
  def edit_profile?(user, options = {})
    self.popv_admin? || self.admin? || (self.warehouse_admin? && user.warehouse? && (options[:role] != true)) || (self.requesting_admin? && user.requesting? && (options[:role] != true))
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, given_password)
    user = find_by_login(login) # need to get the salt
    user && user.crypted_password == self.encrypt(given_password, user.salt) ? user : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    time = 1.week.from_now.utc
    self.remember_token_expires_at = time
    self.remember_token = self.class.encrypt("#{email}--#{remember_token_expires_at}", self.salt)
    save(false)
  end

  # Removes the remember token
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
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
    Employee.column_names.each do |column_name|
      case column_name
        when 'delta'
          #skip
        when 'company_id'
          company 'company_name' do |c| c.name  end
        when 'group_id'
          group 'group_name' do |g| g.try(:name) end
        when 'current_bom_id'
          current_bom 'current_bom_description' do |b| b.try(:description) end
        else
          send(column_name,column_name.underscore)
      end
    end
  end


  protected
  # before_save filter
  def encrypt_password
    return if password.blank?
    self.salt ||= Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{(login || '')}--")
    self.crypted_password = self.class.encrypt(password, self.salt)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def set_start_page
    if [Employee::REQUESTING, Employee::PLANNING, Employee::ADMIN].include?(self.role)
      self.start_page = Employee::MATERIAL_REQUESTS
    else
      self.start_page = Employee::ORDERS
    end
  end

  alias_method :to_s, :full_name
end
