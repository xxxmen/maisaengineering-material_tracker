class AddCurrentPopvTabsToEmployee < ActiveRecord::Migration
  def self.up
  	add_column :employees, :current_popv_tabs, :text
  end

  def self.down
  	remove_column :employees, :current_popv_tabs
  end
end
