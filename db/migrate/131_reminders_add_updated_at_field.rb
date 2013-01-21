class RemindersAddUpdatedAtField < ActiveRecord::Migration
  def self.up
  	add_column :reminders, :updated_at, :datetime
  end

  def self.down
  end
end
