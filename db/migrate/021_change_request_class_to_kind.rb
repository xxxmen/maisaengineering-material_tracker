class ChangeRequestClassToKind < ActiveRecord::Migration
  def self.up
    rename_column :requested_line_items, :class, :kind
  end

  def self.down
    rename_column :requested_line_items, :kind, :class
  end
end
