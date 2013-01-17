# == Schema Information
# Schema version: 20090730175917
#
# Table name: po_statuses
#
#  id     :integer(4)    not null, primary key
#  status :string(255)   
#

class PoStatus < ActiveRecord::Base
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

  ############################################################################
  # INDEXING
  ############################################################################
    
  # Thinking Sphinx Config
  define_index do
    indexes :status
    set_property :delta => true
  end
  ############################################################################
  # VALIDATIONS
  ############################################################################
  
  validates_presence_of :status
  validates_presence_of :order

  has_many :orders, :class_name => "Order", :foreign_key => "status_id"
  FULLY_RECEIVED = "Fully Received"
  PARTIALLY_RECEIVED = "Partially Received"
  WAITING_PMI = "Waiting for PMI"
  def self.fully_received_id
    return PoStatus.find_by_status(FULLY_RECEIVED).id
  end
  
  def self.partially_received_id
    return PoStatus.find_by_status(PARTIALLY_RECEIVED).id
  end
  def self.any_received_ids
    return PoStatus.find(:all, :conditions => {:status => [FULLY_RECEIVED,PARTIALLY_RECEIVED ,WAITING_PMI]}).map{|po| po.id}
  end
  
  def self.list_status
    self.find(:all, :order => "po_statuses.order").map { |s| [s.status, s.id] }
  end

  def self.create_defaults
    self.create(:status => FULLY_RECEIVED)
    self.create(:status => PARTIALLY_RECEIVED)
    self.create(:status => WAITING_PMI)
  end
end
