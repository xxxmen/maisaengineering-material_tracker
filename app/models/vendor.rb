# == Schema Information
# Schema version: 20090730175917
#
# Table name: vendors
#
#  id                :integer(4)    not null, primary key
#  vendor_no         :string(255)   
#  name              :string(255)   
#  email             :string(255)   
#  account_no        :string(255)   
#  address           :string(255)   
#  city              :string(255)   
#  state             :string(255)   
#  zip               :string(255)   
#  country           :string(255)   
#  telephone         :string(255)   
#  fax               :string(255)   
#  contact_name      :string(255)   
#  contact_telephone :string(255)   
#  notes             :text          
#  lock_version      :integer(4)    default(0)
#  updated_at        :datetime      
#  access_key        :string(255)   
#

require 'digest/sha1'

class Vendor < ActiveRecord::Base
  ############################################################################
  # MIXINS
  ############################################################################

  extend Listable::ModelHelper

  ############################################################################
  # CONSTANTS
  ############################################################################

  PERPAGE = 100

  ############################################################################
  # ASSOCIATIONS
  ############################################################################

  acts_as_log_edits
  has_many :orders
  has_and_belongs_to_many :vendor_groups

  ############################################################################
  # INDEXING
  ############################################################################

  # Thinking Sphinx Config
  define_index do
    indexes :vendor_no
    indexes :name
    indexes :account_no
    set_property :delta => true
  end

  ############################################################################
  # CALLBACKS
  ############################################################################

  before_create :set_access_key

  ############################################################################
  # VALIDATIONS
  ############################################################################

  validates_presence_of :name


  ############################################################################
  # INSTANCE METHODS
  ############################################################################


  def self.all_vendors(header = '-- Vendors --')
    options = self.find(:all, :order => "name ASC").map do |v|
      [v.name, v.id]
    end
    if header
      options.unshift([header, nil])
    end
    return options
  end

  def self.list_vendors_by_name
    self.find(:all, :order => "name ASC").map do |v|
      [v.name, v.name]
    end.unshift([nil, nil])
  end

  def self.options_for_overdue
    vendors = Order.find(:all, :select => "DISTINCT(vendor_id)", :conditions =>
        ["purchase_orders.date_eta IS NOT NULL AND
		    purchase_orders.completed = ? AND 
		    po_statuses.status <> ? AND 
		    purchase_orders.date_eta <= CURRENT_DATE AND
		    purchase_orders.vendor_id IS NOT NULL", false, 'INACTIVE'],
                         :include => [:status, :vendor], :order => "vendors.name")
    vendors = vendors.delete_if { |o| o.blank? || o.vendor.blank? }
    vendors = vendors.map do |order|
      [order.vendor.name, order.vendor.name]
    end.uniq
    vendors = vendors.unshift(["UNSPECIFIED", "UNSPECIFIED"]).unshift(['ALL', ''])
    return vendors
  end

  ##
  #	Finds the vendor that matches the passed in value *name* and
  #	returns the telephone number for it if it finds one.
  #
  def self.find_vendors_telephone(name = "")
    phone = ""
    unless name.blank?
      query = "%#{name}%"
      vendor = self.find(:first, :conditions => ["name LIKE ?", query])
      if vendor && !vendor.telephone.blank?
        phone = vendor.telephone
      end
    end
    return phone
  end


  # ===============
  # = CSV support =
  # ===============
  comma do
    Vendor.column_names.each do |column_name|
      case column_name
        when 'delta'
          #skip
        else
          send(column_name ,column_name.underscore)
      end
    end
  end


  ############################################################################
  # PRIVATE
  ############################################################################

  private

  def set_access_key
    self.access_key = Digest::SHA1.hexdigest('--' + self.id.to_s + '--' + Time.now.to_s + '--')
  end
end
