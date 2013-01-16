class RemindersAddSentOnDatetimeField < ActiveRecord::Migration
    def self.up
        add_column :reminders, :sent_on, :datetime
    end

    def self.down
        remove_column :reminders, :sent_on, :datetime
    end
end
