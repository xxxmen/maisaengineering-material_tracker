class ModifyBills < ActiveRecord::Migration
  def self.up
    add_column :bills, :requestor_department, :string, :default => "ENGINEERING"
    add_column :bills, :deliver_to, :string #no default
    add_column :bills, :attention, :string #no default
    add_column :bills, :will_call, :string 
    add_column :bills, :will_call_extension_or_radio, :string 
    add_column :bills, :stage, :boolean #"yes or no"
    
    
  end

  def self.down
    remove_column :bills, :requestor_department
    remove_column :bills, :deliver_to
    remove_column :bills, :attention
    remove_column :bills, :will_call
    remove_column :bills, :will_call_extension_or_radio
    remove_column :bills, :stage
  end
end
