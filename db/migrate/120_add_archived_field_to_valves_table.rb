class AddArchivedFieldToValvesTable < ActiveRecord::Migration
  def self.up
    add_column :valves, :archived, :boolean
  end

  def self.down
    remove_column :valves, :archived
  end
end
