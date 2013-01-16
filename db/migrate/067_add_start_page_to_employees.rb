class AddStartPageToEmployees < ActiveRecord::Migration
  def self.up
    add_column :employees, :start_page, :integer, :default => 1
    # 0 - /home/menu
    # 1 - /orders                (default) - warehouse/warehouse admins
    # 2 - /material_requests     requesters, purchasing, admins, 
    # 3 - /web_requests          
    # 4 - /reports
    Employee.find(:all).each do |employee|
      employee.last_name.blank? ? employee.update_attributes!(:last_name => "NONE") : nil
      
      if [Employee::REQUESTING, Employee::PLANNING, Employee::ADMIN].include?(employee.role)
        employee.update_attributes!(:start_page => 2)
      else
        employee.update_attributes!(:start_page => 1)
      end
    end
  end

  def self.down
    remove_column :employees, :start_page
  end
end
