class NewFieldsForStatesOnRequests < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :web_sent_at, :integer
    add_column :material_requests, :web_received_at, :integer
    add_column :material_requests, :submitted_by, :integer
    add_column :material_requests, :quote_requested_by, :integer
    add_column :material_requests, :partially_authorized_by, :integer
    add_column :material_requests, :declined_by, :integer
    add_column :material_requests, :completed, :boolean, :default => false
    add_column :material_requests, :archived, :boolean, :default => false
    add_column :material_requests, :updated_at, :datetime
    remove_column :material_requests, :declined
  end

  def self.down
    remove_column :material_requests, :web_sent_at
    remove_column :material_requests, :web_received_at
    remove_column :material_requests, :submitted_by
    remove_column :material_requests, :quote_requested_by
    remove_column :material_requests, :partially_authorized_by
    remove_column :material_requests, :declined_by
    remove_column :material_requests, :completed
    remove_column :material_requests, :archived
    remove_column :material_requests, :updated_at
    add_column :material_requests, :declined, :boolean, :default => false
  end
end
