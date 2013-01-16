class AddEmployeeDirectSearchField < ActiveRecord::Migration
  def self.up
    add_column :employees, :direct_search, :boolean, :default => false
  end

  def self.down
    remove_column :employees, :direct_search
  end
end
