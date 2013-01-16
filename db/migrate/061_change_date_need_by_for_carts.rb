class ChangeDateNeedByForCarts < ActiveRecord::Migration
  def self.up
    remove_column :carts, :date_need_by
    add_column :carts, :need_by, :string
  end

  def self.down
    add_column :carts, :date_need_by, :date
    remove_column :carts, :need_by
  end
end
