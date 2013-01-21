# == Schema Information
# Schema version: 121
#
# Table name: purchase_orders
#
#  id                :integer(11)   not null, primary key
#  created           :date          
#  tracking          :text          
#  po_no             :text          
#  description       :text          
#  vendor_id         :integer(11)   
#  status_id         :integer(11)   default(1)
#  deliver_to        :string(255)   
#  work_orders       :string(255)   
#  ptm_no            :text          
#  awr               :boolean(1)    
#  total_cost        :decimal(16, 2 
#  unit_id           :integer(11)   
#  turnaround_year   :text          
#  date_eta          :date          
#  completed         :boolean(1)    
#  closed            :boolean(1)    
#  location          :text          
#  activity          :text          
#  issued_to_history :text          
#  lock_version      :integer(11)   default(0)
#  updated_at        :datetime      
#  record_counter    :integer(11)   
#  planner_id        :integer(11)   
#  requested_by_id   :integer(11)   
#  date_need_by      :date          
#  date_requested    :date          
#  stage             :boolean(1)    
#  suggested_vendor  :string(255)   
#  acknowledged      :boolean(1)    
#  authorized        :boolean(1)    
#  archived          :boolean(1)    
#

class Order < ActiveRecord::Base  
    generator_for :po_no, :start => 'L100' do |prev|
        prev.succ
    end
    
    generator_for :tracking, :start => 'W100' do |prev|
        prev.succ
    end
end
