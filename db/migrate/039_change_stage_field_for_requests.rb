class ChangeStageFieldForRequests < ActiveRecord::Migration
  def self.up
    remove_column :material_requests, :stage_at
    add_column :material_requests, :stage_location, :string
  end

  def self.down
    add_column :material_requests, :stage_at, :datetime
    remove_column :material_requests, :stage_location
  end
end
