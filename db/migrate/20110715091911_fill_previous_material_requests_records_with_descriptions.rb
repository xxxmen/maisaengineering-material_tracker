class FillPreviousMaterialRequestsRecordsWithDescriptions < ActiveRecord::Migration
    def self.up
        MaterialRequest.find(:all).each do |material_request|
        	if(!material_request.items_sorted.empty?)
        		@description = material_request.items_sorted.first.material_description
        	else
        		@description = ''
        	end

            material_request.update_attribute :description, @description
        end
    end
end
