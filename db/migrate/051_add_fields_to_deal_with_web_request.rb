class AddFieldsToDealWithWebRequest < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :drafted_by, :integer
    add_column :material_requests, :request_state, :integer, :default => 0
  end

  def self.down
    remove_column :material_requests, :drafted_by
    remove_column :material_requests, :request_state
  end
end
