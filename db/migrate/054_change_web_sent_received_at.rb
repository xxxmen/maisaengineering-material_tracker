class ChangeWebSentReceivedAt < ActiveRecord::Migration
  def self.up
    remove_column :material_requests, :web_sent_at
    remove_column :material_requests, :web_received_at
    add_column :material_requests, :web_sent_at, :datetime
    add_column :material_requests, :web_received_at, :datetime
    
    Cart.find(:all).each do |cart|
      request = MaterialRequest.find_by_tracking(cart.tracking_no)
      if request
        request.web_sent_at = Time.now.to_s(:db)
        if cart.closed?
          request.web_received_at = Time.now.to_s(:db)
        end
        request.save
      end
    end
  end

  def self.down
    remove_column :material_requests, :web_sent_at
    remove_column :material_requests, :web_received_at
    add_column :material_requests, :web_sent_at, :integer
    add_column :material_requests, :web_received_at, :integer
  end
end
