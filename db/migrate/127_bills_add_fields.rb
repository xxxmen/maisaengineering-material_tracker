class BillsAddFields < ActiveRecord::Migration
  def self.up
    add_column :bills, :ticket, :string
    add_column :bills, :approved_by, :integer
  end

  def self.down
    remove_column :bills, :ticket
    remove_column :bills, :approved_by    
  end
end
