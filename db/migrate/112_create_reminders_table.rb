class CreateRemindersTable < ActiveRecord::Migration
    def self.up
      create_table :reminders do |t|
        t.integer   :po_id
        t.text    :email_to
        t.date  :send_reminder_on
        t.text      :notes
        t.integer   :created_by
      end
      
      add_index :reminders, :po_id
    end

    def self.down
      drop_table :reminders
    end
end
