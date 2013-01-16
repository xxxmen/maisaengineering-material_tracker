class AddCreatedByToRequests < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :created_by, :integer
    MaterialRequest.find(:all).each do |request|
      request.created_by = request.requested_by_id
      request.save!
    end
  end

  def self.down
    remove_column :material_requests, :created_by
  end
end
