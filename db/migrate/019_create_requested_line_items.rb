class CreateRequestedLineItems < ActiveRecord::Migration
  def self.up
    create_table :requested_line_items do |t|
      t.column :item_no, :integer
      t.column :quantity, :integer
      t.column :unit_of_measure, :string
      t.column :material_description, :text
      t.column :class, :string
      t.column :details, :string
      t.column :material_request_id, :integer
    end
  end

  def self.down
    drop_table :requested_line_items
  end
end
