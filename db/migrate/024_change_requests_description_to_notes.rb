class ChangeRequestsDescriptionToNotes < ActiveRecord::Migration
  def self.up
    rename_column :material_requests, :description, :notes
  end

  def self.down
    rename_column :material_requests, :notes, :description
  end
end
