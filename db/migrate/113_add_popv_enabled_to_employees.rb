class AddPopvEnabledToEmployees < ActiveRecord::Migration
  def self.up
    add_column :employees, :popv_enabled, :boolean
  end

  def self.down
    remove_column :employees, :popv_enabled
  end
end
