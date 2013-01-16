class AddUnitOfMeasureToQuoteItem < ActiveRecord::Migration
  def self.up
    add_column :quote_items, :unit_of_measure, :string
  end

  def self.down
    remove_column :quote_items, :unit_of_measure
  end
end
