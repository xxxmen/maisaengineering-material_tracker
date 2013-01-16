class AddOrderToPoStatus < ActiveRecord::Migration
  def self.up
  	add_column :po_statuses, :order, :integer, :default => 0
  	PoStatus.find(:all).each do |status|
  		status.order = status.id
  		status.save!
  	end
  end

  def self.down
  	remove_column :po_statuses, :order
  end
end
