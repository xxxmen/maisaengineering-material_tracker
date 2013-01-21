class ChangeSentByToEmailedBy < ActiveRecord::Migration
  def self.up
    rename_column :quotes, :sent_by, :emailed_by
  end

  def self.down
    rename_column :quotes, :emailed_by, :sent_by
  end
end
