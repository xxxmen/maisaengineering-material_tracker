class AddRequesterFields < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :planner_id, :integer
    add_column :purchase_orders, :requested_by_id, :integer
    add_column :purchase_orders, :date_need_by, :date
    add_column :purchase_orders, :date_requested, :date
    add_column :purchase_orders, :stage, :boolean
    add_column :purchase_orders, :suggested_vendor, :string
    
    add_column :ordered_line_items, :unit_of_measure, :integer
    add_column :ordered_line_items, :class, :string
    add_column :ordered_line_items, :details, :string
  end

  def self.down
    remove_column :purchase_orders, :planner_id
    remove_column :purchase_orders, :requested_by_id
    remove_column :purchase_orders, :date_need_by
    remove_column :purchase_orders, :date_requested
    remove_column :purchase_orders, :stage
    remove_column :purchase_orders, :suggested_vendor
    
    remove_column :ordered_line_items, :unit_of_measure
    remove_column :ordered_line_items, :class
    remove_column :ordered_line_items, :details
  end
end
