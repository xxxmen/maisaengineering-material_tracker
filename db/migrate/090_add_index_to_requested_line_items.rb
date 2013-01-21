class AddIndexToRequestedLineItems < ActiveRecord::Migration
  def self.up
    add_index "requested_line_items", "material_request_id"
  end

  def self.down
    drop_index "requested_line_items", "material_request_id"
  end
end
