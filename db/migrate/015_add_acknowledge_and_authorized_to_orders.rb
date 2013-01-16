class AddAcknowledgeAndAuthorizedToOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :acknowledged, :boolean, :default => false
    add_column :purchase_orders, :authorized, :boolean, :default => false
    
    # Change all current orders in the database to acknowledged and authorized
    # All future new orders will NOT be either
    Order.update_all("acknowledged = 1, authorized = 1")
  end

  def self.down
    remove_column :purchase_orders, :acknowledged
    remove_column :purchase_orders, :authorized
  end
end
