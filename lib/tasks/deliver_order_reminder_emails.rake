namespace :mailer do
  desc "Delivers all reminders set to go out on the current date."
  task :deliver_order_reminders_for_today => :environment do
    RAILS_DEFAULT_LOGGER.info("=== DELIVER ORDER REMINDER START ===")
    Reminder.email_reminders_for_today
    RAILS_DEFAULT_LOGGER.info("=== DELIVER ORDER REMINDER END ===")
  end
end
