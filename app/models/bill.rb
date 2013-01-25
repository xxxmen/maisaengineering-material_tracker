# == Schema Information
# Schema version: 20090730175917
#
# Table name: bills
#
#  id                           :integer(4)    not null, primary key
#  created_by                   :integer(4)
#  created_at                   :datetime
#  updated_at                   :datetime
#  special_instructions         :text
#  description                  :text
#  status                       :string(255)
#  tracking                     :string(255)
#  work_order                   :string(255)
#  required_on                  :date
#  suggested_vendor             :string(255)
#  delivery_type                :string(255)
#  unit_id                      :integer(4)
#  process                      :string(255)
#  mes                          :string(255)
#  updated_by                   :integer(4)
#  material_request_id          :integer(4)
#  superseded                   :boolean(1)
#  requestor_department         :string(255)   default("ENGINEERING")
#  deliver_to                   :string(255)
#  attention                    :string(255)
#  will_call                    :string(255)
#  will_call_extension_or_radio :string(255)
#  stage                        :boolean(1)
#  default_piping_size          :string(255)
#  ticket                       :string(255)
#  approved_by                  :integer(4)
#  tracking_number_1_type       :string(255)
#  tracking_number_1            :string(255)
#  tracking_number_2_type       :string(255)
#  tracking_number_2            :string(255)
#  tracking_number_3_type       :string(255)
#  tracking_number_3            :string(255)
#

class Bill < ActiveRecord::Base

  ############################################################################
  # MODULES

    extend Listable::ModelHelper
    # Added to include helper methods for dealing with polymorphic piping_references.
  	include PipingReferenceHelper


  ############################################################################
  # ATTRIBUTES

    attr_accessor :bom_data
    # Prevents the named fields from being updated by :new({}), :update_attributes({}), or :attributes={}
    attr_protected :approved_by


  ############################################################################
  # CONSTANTS

    PERPAGE = 100
    PAGE_LIMIT = 40
    PAGE_INCLUDE = [:bill_items, :piping_class_details, :employees, :piping_references]
    PAGE_ORDER_MAPPING = {  :num_items => "(SELECT COUNT(*) AS user_count FROM bill_items AS b1 WHERE b1.bill_id = bills.id)", :created_name => 'employees.last_name' }
    SEXT_SEARCH_FIELDS = ["employees.first_name",'employees.last_name', 'tracking', 'description']

  ############################################################################
  # VALIDATIONS

    validates_presence_of :description, :tracking, :unit_id, :on => :update
    validates_inclusion_of :delivery_type, :in => ['Normal', 'Expedited', 'ASAP'], :allow_nil => true


  ############################################################################
  # CALLBACKS

    after_create :employee_cuurent_a_create
    before_create :employee_cuurent_b_create
    before_save :employee_status_b_save

	def employee_cuurent_a_create
  		#when we create a bill, set the employees current_bom to this one
  		if Employee.current_employee
	  		Employee.current_employee.current_bom_id = self.id
	  		Employee.current_employee.save
  		end
  	end


  	def employee_cuurent_b_create
  		if Employee.current_employee
  			self.created_by = Employee.current_employee.id
  		else
  			self.created_by = 1
  		end

  		self.tracking = Bill.generate_new_tracking_number

  		set_default_reference_number_types
  	end


  	def employee_status_b_save
  		if self.status.blank?
  			self.status = "Draft"
  		end
  		if Employee.current_employee
  			self.updated_by = Employee.current_employee.id
  		else
  			self.updated_by = 1
  		end
  	end

  ############################################################################
  # ASSOCIATIONS

    belongs_to :employee, :foreign_key => 'created_by'
    has_many :bill_items
    has_many :user_notes, :as => :table
    belongs_to :material_request
    belongs_to :unit

    has_many :piping_reference_attachings, :as => :attachable, :dependent => :destroy
    has_many :piping_references, :through => :piping_reference_attachings
  	#acts_as_polymorphic_paperclip


  ############################################################################
  # CLASS METHODS

  	def self.generate_new_tracking_number
  		bill = self.find(:first, :order => 'tracking DESC')
		last_bill_num = 0

  		if bill.present? && bill.tracking.present?
			len = bill.tracking.length
			last_bill_num = bill.tracking[1, len].to_i
  		end

  		return "B" + "%04d" % (last_bill_num + 1)
  	end

  ############################################################################
  # INSTANCE METHODS

    def initialize(*args)
        super(*args)
        self.delivery_type = 'Normal'
        self.stage = false
    end

	def piping_reference_identifier
		self.tracking
	end


	def sext_data(options = {})
	 	json = super()
	  	if self.status.blank?
			json[:status] = "Draft"
	  	end
	  	employee = Employee.find_by_id(self.created_by)
	  	if !employee.blank?
	  		json[:created_name] = employee.full_name
	  	else
	  		json[:created_name] = ''
	  	end

	    json[:stage] = self.stage ? 1 : 0

	  	if self.employee_can_edit?(Employee.current_employee)
	  		json[:is_editable_by_current_user] = true
    	else
   			json[:is_editable_by_current_user] = false
	    end

	  	json[:num_items] = self.bill_items.count
	  	json[:bom_items] = []
	  	if self.bill_items.count > 0
	  		self.bill_items.find(:all, :order => 'line_num ASC').each do |item|
	  			json[:bom_items] << item.sext_data
	  		end
	  	end

	  	if !self.material_request_id.blank?
	  		related_data = {
		  		:label => "Material Request",
		  		:value => self.material_request.tracking,
		  		:command => "window.open",
		  		:args => "/material_requests/" + self.material_request.id.to_s + '/edit'
			}
	  		json[:related_data] = [related_data]
	  	end

	  	# Populates :references_data with an array of piping_reference attributes for
	  	# listing the references of Bills. Defined in PipingReferenceHelper module.
	  	json[:references_data] = self.get_piping_references

	  	return json
	end


	def create_new_copy
		new_attributes = self.attributes.merge({
			:status => "Draft",
            :superseded => false,
            :material_request_id => nil
        })

		new_bill = Bill.create(new_attributes)

	    # Copy all the bill_items over
	    self.bill_items.each do |item|
	    	new_bill.bill_items.create(item.attributes)
    	end

    	return new_bill
	end

	def supersede
		self.status = "Superseded"
		self.superseded = true
		self.save!

		new_bill = self.create_new_copy

		if self.tracking.include?('-')
	        #this regex will substitue a -NUMBER with -NUMBER plus 1
	        #the value[1,value.size] returns the actual value of the second character of the match on
	        #we then add one to it, and return the new value with the dash in front of it
	        new_bill.tracking = self.tracking.sub(/\-[0-9]*$/) do |value|
	        	"-#{((value[1,value.size]).to_i + 1)}"
        	end
	    else
	        new_bill.tracking = self.tracking + "-1"
	    end

    	return new_bill
	end

	def stage_formatted
		if self.stage == true
			"Yes"
		else
			"No"
		end
	end


    # This renames the Bill#create_material_request method that ActiveRecord
    # created when "belongs_to :material_request" was declared at the top of
    # this class so that it can be overridden below.
    alias_method :original_create_material_request, :create_material_request

    # Creates a new MaterialRequest and creates a new RequestedLineItem
    # for each of the associated BillItems for this Bill.
    def create_material_request
    	if self.material_request_id.present? && self.material_request
    		message = "This BOM already has a Material Request associated with it."
    		return self, message
   		end

        # Build the notes string using description and delivery_type fields
        notes_array = [self.description.strip]
        if !self.delivery_type.blank?
            notes_array << "DELIVERY TYPE: #{self.delivery_type.strip}"
        end
        notes_string = notes_array.join(" -- ")

		reference_types, reference_values = get_combined_reference_numbers_and_types

        # Build the Deliver To string using the deliver_to and either attention or
        # will_call fields.
        unless self.deliver_to.blank? && self.attention.blank? && self.will_call.blank?
            deliver_to_array = [self.deliver_to]
            if !self.attention.blank?
                deliver_to_array << "#{self.attention}"
            else
                deliver_to_array << "#{self.will_call}"
            end
            deliver_to_string = deliver_to_array.join(" : ")
        else
            deliver_to_string = ""
        end

        # Uses the aliased method defined above to create the material request.
        self.material_request = self.original_create_material_request({
        	:unit_id => self.unit_id,
        	:requested_by_id => self.created_by,
        	:drafted_by => self.created_by,
        	:work_orders => self.work_order,
        	:date_requested => self.created_at,
        	:date_need_by => self.required_on,
        	:suggested_vendor => self.suggested_vendor,
        	:activity => self.special_instructions,
        	:notes => notes_string,
        	:reference_number_type => reference_types,
        	:reference_number => reference_values,
        	:deliver_to => deliver_to_string,
        	:telephone => will_call_extension_or_radio
        })

        # Creates new RequestedLineItems for each BillItem
        self.bill_items.each do |bill_item|
            create_requested_line_item(bill_item)
        end

        # Set the status to "Created" now that the material request is assigned.
        self.status = "Created"

        # A failed save here will bubble the exception to the caller.
        self.save!

        # If there are errors with the material request, return it instead
        # of the bill (self) so that the errors can show up in the form.
        if self.material_request.errors.blank?
            return self, "Material Request #{self.material_request.tracking} successfully created."
        else
            return self.material_request, "Please fix the errors on this BOM and try creating again."

        end
    end


    # Creates a new requested line item for the assigned material request based on
    # a Bill Item passed in.
    def create_requested_line_item(bill_item)
        requested_line_item_config = bill_item.convert_to_requested_line_item
        self.material_request.items.create(requested_line_item_config)
  	end


    def extract_sizes(first, second)
        if first.blank? && second.blank?
            return ""
        elsif first.blank?
            return second
        elsif second.blank?
            return first
        else
            return first + " x " + second
        end
    end


  	##
  	#	Searches for a the suggested_vendor in the Vendors table and
  	#	returns the associated phone number if it finds one. Used
  	# 	primarily for the Form 58001 XML file.
  	#
  	def find_related_vendor_telephone
  		unless self.suggested_vendor.blank?
  			Vendor.find_vendors_telephone(self.suggested_vendor)
 		else
 			""
 		end
 	end


  	def bom_data=(local_data)
  		if local_data.blank?
  			return true
  		end
  		items = ActiveSupport::JSON.decode(local_data)

  		items.each do |this_item|
  			if this_item['id'].blank?
  				self.bill_items.build(:attributes => this_item)
  			else
  				this_item_id = this_item['id']
  				updating_item = BillItem.find(this_item_id)
  				updating_item.update_attributes(this_item)
  				updating_item.save
  			end
  		end
  	end


 	def employee_can_edit?(employee)
      	 employee.present? && (employee.popv_admin? || (employee['id'] == self.created_by))
	end

 	##
 	#	Grabs all bill items for the passed in bill ID and returns an array
 	#	of arrays, with the inner arrays being max-length "chunk_size".
 	#	Used for iterating over the records to populate each page of the XML.
 	#
 	def self.find_items_for_xml_export(bill_id, chunk_size = 10)
 		items = self.find_items_for_export(bill_id)

 		bill_items_array = []

  		size = items.size

  		if size > 0
  			divisor = chunk_size
	  		quotient = size / divisor
	  		remainder = size % divisor

			if quotient > 0
				quotient = remainder > 0 ? quotient + 1 : quotient
	  			quotient.times do |i|
  					bill_items_array << items.slice((i * divisor), divisor)
 				end
			else
				bill_items_array << items
			end
		end
		return bill_items_array
	end


 	def self.find_items_for_export(bill_id)
		 return self.find_by_sql("SELECT 
  requesters.first_name AS requester_first_name, 
  requesters.last_name AS requester_last_name, 
  requesters.telephone as requester_telephone, 
  units.description as unit_description, 
  TRIM(CONCAT(IF(units.unit_no IS NOT NULL AND units.unit_no != '', CONCAT(units.unit_no, ' : '), ''), units.description)) as unit_no, 
  bills.work_order as work_order, 
  bills.id as bill_id,
  bills.description as description,
  bills.required_on as required_on, 
  bills.tracking as tracking, 
  bills.process as process, 
  bills.mes as mes,
  bills.suggested_vendor as suggested_vendor, 
  bills.delivery_type as delivery_type, 
  bills.special_instructions as special_instructions,
  bills.status as status, 
  bill_items.line_num as item_no,
  bill_items.quantity as quantity, 
  bill_items.unit_of_measure as unit_of_measure, 
  CONCAT(
	IF(bill_items.size_1 = '' OR bill_items.size_1 IS NULL, bill_items.size_2, IF(bill_items.size_2 = '' OR bill_items.size_2 IS NULL, bill_items.size_1, CONCAT(bill_items.size_1, ' x ', bill_items.size_2))), 
    IF(piping_components.piping_component IS NOT NULL, CONCAT(' ', piping_components.piping_component), ''),
	', ', 
	bill_items.description) as `line_description`, 
  bill_items.notes as notes,
  piping_classes.class_code as class_code,
  bills.requestor_department as requestor_department,
  bills.deliver_to as deliver_to,
  bills.attention as attention,
  bills.will_call as will_call,
  bills.will_call_extension_or_radio as will_call_extension_or_radio,
  bills.stage as stage,
  bills.reference_number_1 as reference_1,
  bills.reference_number_2 as reference_2,
  bills.reference_number_3 as reference_3
   
FROM
 
  bills 
  LEFT JOIN units ON (units.id=bills.unit_id)
  LEFT JOIN bill_items ON (bills.id=bill_items.bill_id)
  LEFT JOIN employees AS requesters ON (requesters.id=bills.created_by) 
  LEFT JOIN piping_class_details ON (bill_items.piping_class_detail_id=piping_class_details.id)
  LEFT JOIN piping_components ON (piping_class_details.piping_component_id=piping_components.id)
  LEFT JOIN piping_classes ON (piping_class_details.piping_class_id = piping_classes.id)

WHERE
  bills.id = #{bill_id}
  ORDER BY bills.tracking, bill_items.line_num ASC
    ;")
	end

	def get_unit_info
		self.unit ?	self.unit.number_and_description : ''
	end

  def self.options_for_xls
    return [['Form 58001','form_58001'],['Turnaround Planning Department Work Package Template','turnaround_planning_department_work_package_template']]
  end


  ##############################################################################
  private

	# Returns ['String of tracking types', 'String of tracking numbers']
	# Values in string are '/' seperated if more than one number and type given.
	def get_combined_reference_numbers_and_types
		reference_types = []
		reference_numbers = []

		[1,2,3].each do |num|
			reference_type = value = nil

			reference_type = self.send("reference_number_#{num}_type")
			value = self.send("reference_number_#{num}")

			reference_types << reference_type if reference_type.present?
			reference_numbers << value if value.present?
		end
		return [reference_types.join('/'), reference_numbers.join('/')]
	end

	def set_default_reference_number_types
		types = ReferenceNumberType.find(:all, :order => 'order_number ASC', :limit => 3).map {|t| t.name }
		self.reference_number_1_type ||= types[0] if types[0]
		self.reference_number_2_type ||= types[1] if types[1]
		self.reference_number_3_type ||= types[2] if types[2]
	end


end
