class AddCurrentBomToEmployees < ActiveRecord::Migration
  def self.up
  	add_column :employees, :current_bom_id, :integer
  end

  def self.down
  	remove_column :employees, :current_bom_id
  end
end
