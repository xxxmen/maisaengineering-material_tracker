class AddSeenUpdateToEmployees < ActiveRecord::Migration
  def self.up
    add_column :employees, :seen_updates, :boolean, :default => true
    Employee.find(:all).each do |employee|
      employee.update_attributes!(:seen_updates => true)
    end
  end

  def self.down
    remove_column :employees, :seen_updates
  end
end
