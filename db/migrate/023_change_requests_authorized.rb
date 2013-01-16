class ChangeRequestsAuthorized < ActiveRecord::Migration
  def self.up
    change_column :material_requests, :authorized, :boolean
  end

  def self.down
    change_column :material_requests, :authorized, :integer
  end
end
