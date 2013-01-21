class RemoveWebRequestsFromMaterialRequestsTable < ActiveRecord::Migration
  def self.up
    MaterialRequest.find(:all, :conditions => "web_sent_at IS NOT NULL").each do |request|
      request.destroy
    end
    
    remove_column :material_requests, :web_sent_at
    remove_column :material_requests, :web_received_at
  end

  def self.down
    add_column :material_requests, :web_sent_at, :datetime
    add_column :material_requests, :web_received_at, :datetime
  end
end
