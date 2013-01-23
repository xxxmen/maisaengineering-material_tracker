# This class is made to store permissions for what Controllers the web users
# may use and see.
# The permissions are loaded into @@resources, a class variable, at the time of
# this file being loaded (the last line calls the loading of resource permissions)
# It also initializes the data in the accounts table with the RESOURCES array.

class ResourcePermission < ActiveRecord::Base
	
	cattr_accessor :resources
	
	RESOURCES = [
		:carts,
		:events,
		:general_references,
		:groups,
		:inventory_items,
		:live,
		:material_requests,
		:orders,
		:popv,
		:quotes,
		:reference_numbers,
		:reports,
		:hide_pricing
	]
	############################################################################
	# CLASS METHODS
	
	def self.load_resource_permissions
		@@resources = {}
		resources = self.find(:all)
		resources.each do |resource|
			 @@resources[resource.name.to_s] = resource.enabled
		end
	end

	# Creates the entries in the accounts table automatically.
	def self.initialize_resources(enabled = false)
		if self.table_exists?
			RESOURCES.each do |resource_name|
				resource = self.get_resource(resource_name)
			end

			self.load_resource_permissions	
		end
	end
	
	def self.is_enabled?(controller_name)
		@@resources[controller_name.to_s] || false
	end
	
	def self.list
		self.find(:all, :order => 'name ASC').each do |resource|			
			puts "#{resource.name.ljust(30, '.')}#{resource.enabled}"
		end
		nil
	end
	
	# Sets a resource to enabled
	def self.enable(resource)
		account = self.get_resource(resource)
		account.enabled = true
		account.save
		self.list
	end

	# Sets a resource to disabled
	def self.disable(resource)
		account = self.get_resource(resource)
		account.enabled = false
		account.save
		self.list
	end
	
	# Sets all resources to enabled
	def self.enable_all
		self.find(:all).each do |resource|
			resource.enabled = true
			resource.save
		end
		self.list
	end
	
	
	# Sets all resources to disabled
	def self.disable_all
		self.find(:all).each do |resource|
			resource.enabled = false
			resource.save
		end
		self.list
	end
	
	def self.get_resource(resource_name)
		resource_name = resource_name.to_s
		resource = self.find_by_name(resource_name)
		if resource.blank?
			resource = self.create(:name => resource_name, :enabled => false)
		end
		return resource
	end

  if Rails.env.development?
    self.initialize_resources
  end
	
end
