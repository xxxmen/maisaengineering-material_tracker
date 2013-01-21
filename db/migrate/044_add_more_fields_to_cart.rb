class AddMoreFieldsToCart < ActiveRecord::Migration
  STRINGS = [:year, :ptm_no, :work_orders, :telephone, :deliver_to, :suggested_vendor]
  INTEGERS = [:purchaser_id, :planner_id]
  DATES = [:date_need_by]
  TEXT = [:notes]
  
  def self.up
    STRINGS.each { |col| add_column :carts, col, :string }
    INTEGERS.each { |col| add_column :carts, col, :integer }
    DATES.each { |col| add_column :carts, col, :date }
    TEXT.each { |col| add_column :carts, col, :text }
  end

  def self.down
    (STRINGS + INTEGERS + DATES + TEXT).each { |col| remove_column :carts, col }
  end
end