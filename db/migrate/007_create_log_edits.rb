class CreateLogEdits < ActiveRecord::Migration
  def self.up
    create_table :log_edits do |t|
      t.column :loggable_id, :integer
      t.column :loggable_type, :string
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :log_edits
  end
end
