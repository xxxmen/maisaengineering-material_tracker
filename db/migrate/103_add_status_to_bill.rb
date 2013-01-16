class AddStatusToBill < ActiveRecord::Migration
  def self.up
  	add_column :bills, :status, :string
  end

  def self.down
  	remove_column :bills, :status
  end
end
