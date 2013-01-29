# == Schema Information
# Schema version: 20090730175917
#
# Table name: events
#
#  id              :integer(4)    not null, primary key
#  employee_id     :integer(4)    
#  recordable_id   :integer(4)    
#  recordable_type :string(255)   
#  created_at      :datetime      
#  description     :text          
#  updated_at      :datetime      
#

class Event < ActiveRecord::Base  
  belongs_to :employee
  belongs_to :recordable, :polymorphic => true
  
  before_validation :set_employee, :on => :create
  
  validates_presence_of :recordable_id
  validates_presence_of :recordable_type
  validates_presence_of :description
  
  extend Listable::ModelHelper
  
  PERPAGE = 100
  
  def self.filter(params, employee)
    if employee.need_details?
      conditions = "1 = 1"
    else
      conditions = "events.recordable_type != 'Quote'"
    end
    args = []
    
    if !params[:record].blank?
      conditions += " AND events.recordable_type = ?"
      args.push(params[:record])
    end
    if !params[:employee].blank?
      conditions += " AND events.employee_id = ?"
      args.push(params[:employee])
    end
    if !params[:start_date].blank?
      conditions += " AND date(events.updated_at) >= ?"
      args.push(params[:start_date].to_date)
    end
    if !params[:end_date].blank?
      conditions += " AND date(events.updated_at) <= ?"
      args.push(params[:end_date].to_date)
    end
    
    args = args.unshift(conditions)
    
    self.with_scope(:find => { :conditions => args }) { yield }
  end
  
  def self.recent_for?(record)
    employee_id = Employee.current_employee ? Employee.current_employee.id : nil
    record_type = record.class.to_s
    
    event = self.with_scope(:find => { :conditions => { :employee_id => employee_id }}) do
      self.find(:first, :conditions => ["recordable_type = ? AND recordable_id = ? AND created_at > ?", record_type, record.id, 1.day.ago])
    end
    
    if event
      event.updated_at = Time.now
      event.save
      return true
    else
      return false
    end    
  end
  
  def employee_name
    if self.employee
      return self.employee.short_name
    elsif self.recordable_type == "Quote"
      return "vendor"
    else
      return "Admin"
    end
  end
  
  def self.all_employees
    employee_ids = Event.find(:all, :select => "distinct(employee_id)").map(&:employee_id)
    return Employee.find(employee_ids, :order => "first_name")
  end
  
  def self.all_records
    Event.find(:all, :order => "recordable_type", :select => "distinct(recordable_type)").map(&:recordable_type)
  end
  
  def show_record
    if self.recordable.is_a?(MaterialRequest)
      return "tracking ##{self.recordable.tracking}"
    elsif self.recordable.is_a?(Order)
      return "po ##{self.recordable.po_no}"
    elsif self.recordable.is_a?(Email)
      return "view email"
    elsif self.recordable.is_a?(Quote)
      return "view quote"
    elsif self.recordable.is_a?(Cart)
      return "web request ##{self.recordable.tracking_no}"
    else
      raise NotImplementedError
    end
  end  
  
  private
  def set_employee
    self.employee ||= Employee.current_employee
  end
end
