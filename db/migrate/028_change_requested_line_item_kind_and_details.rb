class ChangeRequestedLineItemKindAndDetails < ActiveRecord::Migration
  def self.up
    rename_column :requested_line_items, :details, :notes
    remove_column :requested_line_items, :kind
  end

  def self.down
    add_column :requested_line_items, :kind, :string
  end
end
