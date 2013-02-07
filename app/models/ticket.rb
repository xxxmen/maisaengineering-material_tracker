class Ticket < ActiveRecord::Base
  ############################################################################
  # MIXINS
  ############################################################################

  extend Listable::ModelHelper

  ############################################################################
  # CONSTANTS
  ############################################################################

  CONTEXTS = [
      'General',
      'Orders',
      'Requests',
      'Reports',
      'POPV'
  ]

  PRIORITIES = [
      'Low',
      'High',
      'Urgent'
  ]

  STATES = [
      'New',
      'Active',
      'Testing',
      'Rejected',
      'Closed'
  ]

  CATEGORIES = [
      'Bug',
      'Feature',
      'Comment'
  ]

  PERPAGE = 30

  ############################################################################
  # VALIDATIONS
  ############################################################################

  has_attached_file :attachment,
                    :path => ":rails_root/data/tickets/:id_partition/:basename.:extension",
                    :url => "/tickets/attachment/:id"

  ############################################################################
  # VALIDATIONS
  ############################################################################

  validates_presence_of :category, :title, :context, :priority, :reported_by

  ############################################################################
  # CALLBACKS
  ############################################################################

  after_create :send_new_ticket_email

  ############################################################################
  # CLASS METHODS
  ############################################################################


  def self.list_all(params, options = {})
    self.list(params, options)
  end


  def self.get_next_number
    last_ticket = self.find(:first, :order => 'tickets.number DESC')
    last_number = last_ticket ? last_ticket.number : 0
    last_number.to_i + 1
  end


  def self.search_for(params, options = {})
    filter = FilterFoo.new
    q = params[:q]
    filter.or do |f|
      f.like q, "tickets.category"
      f.like q, "tickets.priority"
      f.like q, "tickets.state"
      f.like q, "tickets.title"
      f.like q, "tickets.body"
      f.like q, "tickets.response"
      f.like q, "tickets.context"
      f.like q, "tickets.assigned_to"
      f.like q, "tickets.reported_by"
    end
    with_scope(:find => { :conditions => filter.conditions }) do
      self.list_all(params)
    end
  end

  def self.filter(params, employee)
    if(params[:state] == "all")
      params.delete(:state)
    end
    if(params[:category] == "all")
      params.delete(:category)
    end

    if(params[:priority] == "all")
      params.delete(:priority)
    end
    state = params[:state]
    category = params[:category]
    priority = params[:priority]
    string = "1 = 1"
    string += " AND state = ?" if !state.blank?
    string += " AND category = ?" if !category.blank?
    string += " AND priority = ?" if !priority.blank?

    conditions = [string]
    conditions.push(state) if !state.blank?
    conditions.push(category) if !category.blank?
    conditions.push(priority) if !priority.blank?

    self.with_scope(:find => { :conditions => conditions }) do
      yield
    end
  end
  def self.list_state_for_select(header = '-- State --')

    options = STATES.map {|group| [group, group] }
    if header
      options.unshift([header, "all"])
    end
    return options
  end

  def self.list_category_for_select(header = '-- Category --')
    options = CATEGORIES.map {|group| [group, group] }
    if header
      options.unshift([header, "all"])
    end
    return options
  end

  def self.list_priority_for_select(header = '-- Priority --')
    options = PRIORITIES.map {|group| [group, group] }
    if header
      options.unshift([header, "all"])
    end
    return options
  end

  ############################################################################
  # INSTANCE METHODS
  ############################################################################

  def initialize(*args)
    super(*args)
    self.number = Ticket.get_next_number
    self.state ||= STATES[0]
    self.category ||= CATEGORIES[0]
    self.priority ||= PRIORITIES[0]
    self.context ||= CONTEXTS[0]
  end

  def send_new_ticket_email
    RequestMailer.new_ticket(self).deliver
  end

  def check_referral(referral)
    if referral == 'carts' || referral == 'material_requests'
      referral = 'requests'
    end
    matching_index = 0
    CONTEXTS.each_with_index do |value, index|
      if value.downcase == referral
        matching_index = index
      end
    end
    self.context = CONTEXTS[matching_index]
  end

end
