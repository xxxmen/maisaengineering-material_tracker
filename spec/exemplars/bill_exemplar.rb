# == Schema Information
# Schema version: 121
#
# Table name: bills
#
#  id                           :integer(11)   not null, primary key
#  created_by                   :integer(11)   
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
#  unit_id                      :integer(11)   
#  process                      :string(255)   
#  mes                          :string(255)   
#  updated_by                   :integer(11)   
#  material_request_id          :integer(11)   
#  superseded                   :boolean(1)    
#  requestor_department         :string(255)   default("ENGINEERING")
#  deliver_to                   :string(255)   
#  attention                    :string(255)   
#  will_call                    :string(255)   
#  will_call_extension_or_radio :string(255)   
#  stage                        :boolean(1)    
#  default_piping_size          :string(255)   
#

class Bill < ActiveRecord::Base  
	
    generator_for :description, :start => "Bill Description 1" do |prev|
    	prev.succ
   	end
    
    generator_for :unit_id, :start => 1
    
    generator_for :tracking, :start => "1" do |prev|
        prev.succ
    end
end


