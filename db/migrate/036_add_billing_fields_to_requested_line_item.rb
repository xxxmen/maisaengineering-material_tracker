class AddBillingFieldsToRequestedLineItem < ActiveRecord::Migration
  def self.up
    add_column :requested_line_items, :klass, :string
    add_column :requested_line_items, :component, :string
    add_column :requested_line_items, :subcomponent, :string
    add_column :requested_line_items, :size, :string
  end

  def self.down
    remove_column :requested_line_items, :klass
    remove_column :requested_line_items, :component
    remove_column :requested_line_items, :subcomponent
    remove_column :requested_line_items, :size
  end
end
