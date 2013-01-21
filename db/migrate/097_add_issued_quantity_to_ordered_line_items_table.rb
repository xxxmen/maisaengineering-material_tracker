class AddIssuedQuantityToOrderedLineItemsTable < ActiveRecord::Migration
    def self.up
        add_column :ordered_line_items, :issued_quantity, :integer
    end

    def self.down
    end
end
