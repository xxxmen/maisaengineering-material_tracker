class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.integer  :employee_id, :recordable_id
      t.string   :recordable_type
      t.text     :content, :to, :from, :subject
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :emails
  end
end
