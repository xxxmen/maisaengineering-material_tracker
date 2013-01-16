class CreateMaterialRequestOrderJoin < ActiveRecord::Migration
  def self.up
    create_table :material_requests_orders, :id => false do |t|
      t.integer :material_request_id, :order_id
    end
    
    # Go through each order and material request with the same tracking #
    # Create an entry in the JOIN table for them
    orders = Order.find(:all, :conditions => "(SELECT COUNT(*) FROM material_requests WHERE material_requests.tracking = purchase_orders.tracking) > 0")
    orders.each do |order|
      order.material_requests << MaterialRequest.find(:all, :conditions => { :tracking => order.tracking } )
    end
  end

  def self.down
    drop_table :material_requests_orders
  end
end
