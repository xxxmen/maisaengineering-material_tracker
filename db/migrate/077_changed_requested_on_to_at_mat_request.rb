class ChangedRequestedOnToAtMatRequest < ActiveRecord::Migration
  def self.up
    change_column :material_requests, :date_requested, :datetime
  end

  def self.down
    change_column :material_requests, :date_requested, :date
  end
end
