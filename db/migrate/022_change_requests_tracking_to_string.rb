class ChangeRequestsTrackingToString < ActiveRecord::Migration
  def self.up
    change_column :material_requests, :tracking, :string
  end

  def self.down
    change_column :material_requests, :tracking, :integer
  end
end
