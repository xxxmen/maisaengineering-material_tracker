class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer  :employee_id, :recordable_id
      t.string   :recordable_type
      t.datetime :created_at
      t.text     :description
    end
  end

  def self.down
    drop_table :events
  end
end
