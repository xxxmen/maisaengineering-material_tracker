class AddSupersededFlagToBills < ActiveRecord::Migration
  def self.up
  	add_column :bills, :superseded, :boolean
  end

  def self.down
  	remove_column :bills, :superseded
  end
end
