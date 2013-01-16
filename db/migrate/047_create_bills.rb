class CreateBills < ActiveRecord::Migration
  def self.up
    create_table :bills do |t|
      t.integer :employee_id, :approved_by_id, :reviewed_by_id
      t.boolean :approved, :reviewed, :requested, :default => false
      t.timestamps 
    end
  end

  def self.down
    drop_table :bills
  end
end
