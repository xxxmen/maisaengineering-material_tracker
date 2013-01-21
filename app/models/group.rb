class Group < ActiveRecord::Base
	
	############################################################################
	# ATTRIBUTES
	############################################################################
	# Tells the object to skip the #reset_defaults method on save.
	@@skip_default_callback = false
	cattr_accessor :skip_default_callback
	
	############################################################################
	# ASSOCIATIONS
	############################################################################
	
	has_many :employees
	has_many :orders
	has_many :material_requests
	
	############################################################################
	# VALIDATIONS
	############################################################################
	
	validates_presence_of :name
	
	
	############################################################################
	# CALLBACKS
	############################################################################
	
	before_save :reset_defaults
	before_destroy :check_for_associated_records
	
	############################################################################
	# CLASS METHODS
	############################################################################
	
	def self.list_all
		self.all(:order => 'name ASC')
	end
	
	def self.list_all_for_select(header = '-- Groups --')
		groups = self.list_all
		options = groups.map {|group| [group.name, group.id] }
		if header
			options.unshift([header, nil])
		end
		return options
	end
	
	def self.get_default
		self.find(:first, :conditions => {:default => true})
	end
	
	def self.get_default_id
		default_group = self.get_default
		default_group.present? ? default_group.id : nil		
	end
	
	############################################################################
	# INSTANCE METHODS
	############################################################################
	
	# Cancels the #destroy call if it associated with other records.
	# This way admins can only delete unattached groups.
	def check_for_associated_records
		unless self.employees.blank? && self.material_requests.blank? && self.orders.blank?
			return false
		end
	end
		
	def reset_defaults
		unless @@skip_default_callback
			if self.default == true || self.default == '1'
				default_groups = Group.find(:all, :conditions => {:default => true})
				default_groups.each do |grp|
					grp.default = false
					grp.skip_default_callback = true
					grp.save
				end
			end
		end
	end
	
end
