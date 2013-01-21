class ChangeCartFields < ActiveRecord::Migration
  def self.up
    remove_column :carts, :ptm_no
    remove_column :carts, :suggested_vendor
    remove_column :carts, :work_orders
    remove_column :carts, :stage_location
    add_column :carts, :sent_at, :datetime
    add_column :carts, :received_at, :datetime
    Cart.find(:all).each do |cart|
      if cart.request
        req = cart.request
        cart.sent_at = req.web_sent_at
        cart.received_at = req.web_received_at
        cart.save!
      else
        cart.sent_at = Time.now.to_s(:db)
        if cart.received?
          cart.received_at = Time.now.to_s(:db)
        end
        cart.save!
      end
    end
  end

  def self.down
    add_column :carts, :ptm_no, :string
    add_column :carts, :suggested_vendor, :string
    add_column :carts, :work_orders, :string
    add_column :carts, :stage_location, :string
    remove_column :carts, :sent_at
    remove_column :carts, :received_at
  end
end
