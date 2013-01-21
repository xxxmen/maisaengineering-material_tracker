class DropRecordableOnEmails < ActiveRecord::Migration
  def self.up
    remove_column :emails, :recordable_id
    remove_column :emails, :recordable_type
  end

  def self.down
    add_column :emails, :recordable_id
    add_column :emails, :recordable_type    
  end
end
