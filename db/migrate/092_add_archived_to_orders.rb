class AddArchivedToOrders < ActiveRecord::Migration
  def self.up
     add_column :purchase_orders, :archived, :boolean, :default => false
  end

  def self.down
    remove_column :purchase_orders, :archived
  end
end
