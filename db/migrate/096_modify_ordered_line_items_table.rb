class ModifyOrderedLineItemsTable < ActiveRecord::Migration
    def self.up
        change_column :ordered_line_items, :unit_of_measure, :string
        add_column :ordered_line_items, :location,  :string
        add_column :ordered_line_items, :issued_date,  :date
        add_column :ordered_line_items, :issued_to_name,  :string
        add_column :ordered_line_items, :issued_to_company,  :string
    end

    def self.down
        change_column :ordered_line_items, :unit_of_measure, :integer
        remove_column :ordered_line_items, :location
        remove_column :ordered_line_items, :issued_date
        remove_column :ordered_line_items, :issued_to_name
        remove_column :ordered_line_items, :issued_to_company
    end
end
