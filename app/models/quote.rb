# == Schema Information
# Schema version: 20090730175917
#
# Table name: quotes
#
#  id                    :integer(4)    not null, primary key
#  material_request_id   :integer(4)    
#  vendor_id             :integer(4)    
#  notes                 :text          
#  created_at            :datetime      
#  updated_at            :datetime      
#  discussion            :text          
#  discussion_updated_at :datetime      
#  discussion_flag       :boolean(1)    
#  acknowledged_by       :integer(4)    
#  emailed_by            :integer(4)    
#

class Quote < ActiveRecord::Base
	extend Listable::ModelHelper
	############################################################################
	# ACCESSORS
	############################################################################
  	attr_writer :total_price
  	attr_accessor :current_employee_id
  
	############################################################################
	# ASSOCIATIONS
	############################################################################
  	belongs_to :material_request
  	belongs_to :vendor
  	belongs_to :acknowledger, :class_name => "Employee", :foreign_key => "acknowledged_by"
  
  	has_many :quote_items, :dependent => :destroy
  	has_many :events, :as => :recordable
  	has_many :quote_attachments, :dependent => :destroy
  

   	# Thinking Sphinx Config
	# define_index do
	# 	# Columns
	# 	indexes discussion
	# 	indexes material_request(:tracking), :as => :tracking
	# 	indexes vendor(:name), :as => :supplier
	# 	indexes vendor(:contact_name), :as => :vendor_name
	# 	indexes vendor(:contact_telephone), :as => :vendor_phone
	# 	indexes notes
	# 	indexes acknowledger(:first_name), :as => :acknowledger_first
	# 	indexes acknowledger(:last_name), :as => :acknowledger_last
	#     set_property :delta => true
	# end
 #  	#acts_as_polymorphic_paperclip
  	
	############################################################################
	# VALIDATIONS
	############################################################################
  	validates_presence_of :vendor_id

	############################################################################
	# CALLBACKS
	############################################################################
  	after_create :create_event
  	after_update :update_event

	PERPAGE = 50


	############################################################################
	# CLASS METHODS
	############################################################################

	# Given the material_request, vendor, and current employee logged in
	# This method will find the quote or create one if it doesn't already exist
	def self.find_or_create(material_request, vendor, request_param = nil)
		
		quote = Quote.find(:first, :conditions => { :material_request_id => material_request.id, :vendor_id => vendor.id })
		if !quote 
		    quote = Quote.create!(:material_request_id => material_request.id, :vendor_id => vendor.id)
		    @quote_created = 1
		    material_request.items.each do |item|
			    quote.quote_items.build({
			    	:requested_line_item_id => item.id, 
			    	:item_no => item.item_no, 
			        :notes => item.material_description, 
			        :unit_of_measure => item.unit_of_measure, 
			        :quantity => item.quantity
			    })
		    end
		    
		    quote.save!
		end
		#Attach the files from the material request if we've selected them in the _request_attachments_for_quote partial
		if(!request_param.nil?)
	    	if(!request_param[:attachments].blank?)
	    		request_param[:attachments].each do |att_id|
	    			#skip it if it's blank
	    			if(att_id.blank?)
	    				next
	    			end
	    			#otherwise, we want to import that attachment ID to the quote
	    			if(MaterialRequestAttachment.exists?(att_id))	    				
	    				mr = MaterialRequestAttachment.find(att_id)
	    				file = mr.attachment
	    				quote.quote_attachments.create!(:attachment => file) unless file.blank?		    						
	    			end
	    		end
    		end
	    end
		return quote
	end


  def self.filter(params, employee)
    vendor = params[:vendor]
    status = params[:status]


    string = "1 = 1"
    string += " AND vendor_id = ?" if !vendor.blank?

    conditions = [string]
	conditions.push(vendor) if !vendor.blank?
    if(!status.blank?)
    	case status
	    when "mine"
	      conditions[0] += " AND material_requests.requested_by_id = ?"
	      conditions.push(employee.id)
	    when "all"  
	      
	    when "all_drafts"        
	      conditions[0] += " AND material_requests.drafted_by IS NOT NULL AND material_requests.submitted_by IS NULL and material_requests.acknowledged_by IS NULL AND material_requests.authorized_by IS NULL"

	    when "drafts"
	      conditions[0] += " AND material_requests.drafted_by = ? AND material_requests.submitted_by IS NULL AND material_requests.acknowledged_by IS NULL AND material_requests.authorized_by IS NULL"
	      conditions.push(employee.id)
	    when "submitted"
	      conditions[0] +=" AND material_requests.submitted_by IS NOT NULL AND material_requests.acknowledged_by IS NULL AND material_requests.drafted_by IS NULL"
	    when "process_acknowledged"
	      conditions[0] += " AND material_requests.acknowledged_by IS NOT NULL AND material_requests.quote_requested_by IS NULL AND material_requests.authorized_by IS NULL AND material_requests.declined_by IS NULL"
	    when "process_out_for_quote"
	      conditions[0] += " AND material_requests.quote_requested_by IS NOT NULL AND material_requests.authorized_by IS NULL"
	    when "authorized"
	      conditions[0] += " AND material_requests.authorized_by IS NOT NULL AND material_requests.completed = ?"
	      conditions.push(false)
	    when "declined"
	      conditions[0] += " AND material_requests.declined_by IS NOT NULL AND material_requests.completed = ?"
	      conditions.push(false)
	    when "completed"
	      conditions[0] += " AND material_requests.completed = ?"
	      conditions.push(true)
	    when "created_me"
	      conditions[0] += " AND material_requests.created_by = ? OR material_requests.drafted_by = ?"
	      conditions.push(employee.id)
	      conditions.push(employee.id)
	    else # default is mine
	      conditions[0] += " AND material_requests.requested_by_id = ?"
	      conditions.push(employee.id)
	    end
	 end

    
    
    self.with_scope(:find => { :conditions => conditions }) do

      yield
    end
  end

	############################################################################
	# INSTANCE METHODS
	############################################################################

  	def initialize(*args)
    	super
    	self.emailed_by ||= Employee.current_employee.id if Employee.current_employee
    	self.current_employee_id ||= Employee.current_employee.id if Employee.current_employee
  	end
  
  	def sender_full_name
    	if self.emailed_by && (employee = Employee.find(self.emailed_by))
    	  	employee.full_name
    	end
  	end

  	def needed_by
    	if self.material_request
    	  	self.material_request.date_requested
    	end
  	end

  	def uploaded_quote_attachments=(array_of_files)
  		unless array_of_files.blank?
	  		array_of_files.each do |file|
	  			self.quote_attachments.create!(:attachment => file) unless file.blank?
	 		end
		end
  	end
      
  	def uploaded_quote_attachment=(data)
    	unless data.blank?
    	  	self.quote_attachments.create!(:attachment => data)
    	end
  	end
  
  	def acknowledger_name
    	if self.acknowledger
      		self.acknowledger.short_name
    	else
      		""
    	end
  	end

    #return the filled/total count for the quote
    #not filled = items with zero quantity or items with zero price
  	def filled_count
  		count_total = self.quote_items.size
  		count_filled = 0
  		self.quote_items.each do |qi|
  			if((qi.quantity > 0) && (qi.ext_price > 0))
				count_filled += 1
  			end
  		end
  		if(count_total > 0) && count_filled != count_total
  			return " (#{count_filled}/#{count_total}) for "
  		else
  			return ""
  		end
  	end
  
	def total_price
		sum = 0.0
		self.quote_items.each { |q| sum += q.ext_price }
		return sum
	end
	    
	def add_message(message, user)
		return if message.blank?

		user ||= 'anonymous'
		message = "#{user}@#{Time.now.to_s}: " + message

		if self.discussion.blank?
		    self.discussion = message
		else
		    self.discussion = message + "\n\n" + discussion
		end

		return self.save
	end

	def get_json
		tracking = self.material_request ? self.material_request.tracking : ""
		json = [self.id, tracking, self.vendor.name, self.get_url].to_json
	end

	def get_url
		vendor = self.vendor
		return "/material_requests/quote/#{self.material_request_id}?access_key=#{vendor.access_key}&vendor_id=#{self.vendor_id}"
	end

	def update_items_from_request
		if(!material_request.blank?)
			#go through and recreate any missing material_request_items
		    material_request.items.each do |item|
		    	exists = false
		    	self.quote_items.each do |qi|
		    		if(qi.requested_line_item_id == item.id)
		    			exists = true
		    			break
		    		end
		    	end
		    	
		    	if(!exists)
					self.quote_items.build({
						:requested_line_item_id => item.id, 
						:item_no => item.item_no, 
					    :notes => item.material_description, 
					    :unit_of_measure => item.unit_of_measure, 
					    :quantity => item.quantity
					})
					
		    	end
			    
		    end
			self.save!
		    #go back at the end and update the item_no's for all quote items
		    self.quote_items.each do |qi|
		    	if(!qi.requested_line_item.blank?)
			    	qi.item_no = qi.requested_line_item.item_no 
		    		qi.save!
		    	end
	    	end
	    end
	end


	# Used by the old method of attaching files before Paperclip
#	alias_method :uploaded_data_1=, :uploaded_data=
#	alias_method :uploaded_data_2=, :uploaded_data=
#	alias_method :uploaded_data_3=, :uploaded_data=
#	alias_method :uploaded_data_4=, :uploaded_data=
#	alias_method :uploaded_data_5=, :uploaded_data=


	############################################################################
	private
	############################################################################
	
	def create_event
		self.events.create(:description => "new quote #{self.material_request.tracking} for #{self.vendor.name}")
	end

	def update_event
		if !Event.recent_for?(self)
		    self.events.create(:description => "updated quote #{self.material_request.tracking} for #{self.vendor.name}")
		end
	end  
end
