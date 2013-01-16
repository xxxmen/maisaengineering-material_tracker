# == Schema Information
# Schema version: 20090730175917
#
# Table name: bill_items
#
#  id                     :integer(4)    not null, primary key
#  bill_id                :integer(4)    
#  quantity               :integer(4)    
#  piping_class_detail_id :integer(4)    
#  item_no                :integer(4)    
#  unit_of_measure        :string(255)   
#  description            :text          
#  notes                  :text          
#  manual                 :boolean(1)    
#  created_at             :datetime      
#  updated_at             :datetime      
#  size_1                 :string(255)   
#  size_2                 :string(255)   
#  line_num               :integer(4)    
#

class BillItem < ActiveRecord::Base
    
  ############################################################################
  # Attribute Accessors
  ##
    attr_accessor :piping_class
    attr_accessor :piping_component
    attr_accessor :piping_class_id
    attr_accessor :piping_component_id
    attr_accessor :hide_save_icon
    attr_accessor :is_not_owner
    
  ############################################################################
  # Associations
  ##
    belongs_to :bill
    belongs_to :piping_class_detail
    
  ############################################################################
  # Callbacks
  ##  
    before_create :set_line_num
    before_create :set_default_piping_size
    before_create :set_unit_of_measure
    after_save :update_bill_updated_at
    after_destroy :update_bill_updated_at
    
  ##############################################################################
  # Validations
  ## 
    validates_presence_of :description, :if => Proc.new { |b| b.manual? }
  
  ##############################################################################
  # Public Instance Methods
  ##
    def initialize(*args)
        super(*args)
        self.unit_of_measure ||= "EA"
    end
    

    
    # Builds the attributes for a requested line item based off of this bill item.
    def convert_to_requested_line_item       
        return {
            :item_no => self.item_no,
            :material_description => build_requested_line_item_description,
            :notes => self.notes,
            :quantity => self.quantity,
            :unit_of_measure => self.unit_of_measure
        }        
    end
       
    # Set the bills updated_at to the updated_at of the last Bill Item
    def update_bill_updated_at
    	self.bill.updated_at = self.updated_at
    	self.bill.save
    end
  
    # This will get the maximum line item number
    def set_line_num
    	if(self.bill)
    		max_num = 0
    		items = self.bill.bill_items
    		items.each do |item|
    			if(!(item.line_num.blank?) && (item.line_num > max_num))
    				max_num = item.line_num
    			end
    		end
    		self.line_num = max_num + 1
    		return true
    	end
    	return false
    end
  
    # Sets the size_1 field to the associated bill's default piping size
    # if size_1 wasn't set already.
    def set_default_piping_size
        if self.bill
            if self.size_1.blank? && !self.bill.default_piping_size.blank?
                self.size_1 = self.bill.default_piping_size 
            end        
            return true
        else
            return false
        end
    end
    
    # Sets the unit_of_measure to 'FT' (feet) if the associated piping component
    # is a pipe.
    def set_unit_of_measure
        if self.piping_class_detail && self.piping_class_detail.piping_component
            if self.piping_class_detail.piping_component.piping_component == 'PIPE'
                self.unit_of_measure = 'FT'
            end
        end
    end
  
    def display
        self.manual? ? self.description : build_requested_line_item_description
    end

    def sext_data(options = {})
      	json = super()
        if(!self.piping_class_detail.nil?)
            if(!self.piping_class_detail.piping_component.nil?)
                json[:piping_component] = self.piping_class_detail.piping_component.piping_component
                json[:piping_component_id] = self.piping_class_detail.piping_component.id
            end
            
            if(!self.piping_class_detail.piping_class.nil?)      
                json[:piping_class] = self.piping_class_detail.piping_class.class_code
                json[:piping_class_id] = self.piping_class_detail.piping_class.id
            end
        end
        
        if (
           self.bill.present? && 
           self.bill.employee_can_edit?(Employee.current_employee) && 
           self.bill.status == 'Draft'
        )
	       	 json[:is_not_owner] = false
	    else
    		json[:is_not_owner] = true        
   		end
   		
   		json[:unit_of_measure] = self.unit_of_measure || ""
    		
        return json
    end  
  
     def build_requested_line_item_description
        req_item_description = self.description
        
        if self.piping_class_detail
            if self.piping_class_detail.piping_component
                component = self.piping_class_detail.piping_component.piping_component
                req_item_description = component + ", " + req_item_description
            end
        end
        
        sizes = build_piping_sizes_string
                
        if !sizes.blank?
            req_item_description = sizes + " " + req_item_description
        end
        
        return req_item_description
    end   
  ##############################################################################
  private
  ##############################################################################
  
    def piping_component_string
        if !self.piping_class_detail_id.blank?
            return PipingClassDetail.find(self.piping_class_detail_id).piping_component.piping_component 
        else
            return ""
        end
    end
  
    # Builds a string with either/both/none of the two size fields.
    def build_piping_sizes_string
        if size_1.blank? && size_2.blank?
            return ""
        elsif size_1.blank?
            return size_2
        elsif size_2.blank?
            return size_1
        else
            return size_1 + " x " + size_2
        end
    end
    
 

    
end
