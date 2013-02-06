namespace :db do
  desc "Removes database, migrates the database, and loads seed data"
  task :reload => :environment do
    if RAILS_ENV != "development"
    	puts "Not in Development Mode!  Are you sure you want to continue(y/n)"
    	input = STDIN.gets()
    	input = input.gsub!(/[\n]/, "")
    	if !((input.to_s.downcase == 'y')||(input.to_s.downcase == 'yes'))
    			puts "Exiting Task"
    		 exit 0
    	end
    end
    puts "(This file is found in Rails.root/lib/tasks/db_helpers.rake)"
    
    puts "::: Dropping Database :::"
    Rake::Task['db:drop'].invoke
    
    puts "::: Creating Database :::"
    Rake::Task['db:create'].invoke
    
    puts "::: Loading db/schema.rb :::"
    Rake::Task['db:schema:load'].invoke
    
    puts "::: Seeding Data :::"
    Rake::Task['db:seed'].invoke
  end
  
  desc "Backup of Helpdesk Tickets so they don't get lost on a reload of seed data. creates backup "
  task :backup_tickets => :environment do
  	timenow = Time.now

  	abcs = ActiveRecord::Base.configurations
		our_backup_filename = "#{Rails.root}/data/helpdesk_tickets.sql.dump"
		dump_options = "--add-drop-table=FALSE --complete-insert=TRUE --no-create-info=TRUE --insert-ignore=TRUE"
		if(abcs[RAILS_ENV]['password'].blank?)
				dump_command =  "mysqldump #{abcs[RAILS_ENV]['database']} helpdesk_tickets -u #{abcs[RAILS_ENV]['username']} >> #{our_backup_filename} #{dump_options}"
			else
				dump_command =  "mysqldump #{abcs[RAILS_ENV]['database']} helpdesk_tickets -u #{abcs[RAILS_ENV]['username']} -p#{abcs[RAILS_ENV]['password']} >> #{our_backup_filename} #{dump_options}"
			end
			puts "Backing up using command:"
			puts "#{dump_command}"
			system dump_command
  end
  
  desc "Restore of Helpdesk Tickets so they don't get lost on a reload of seed data. This will delete the backup"
  task :restore_tickets => :environment do
  	timenow = Time.now

  	abcs = ActiveRecord::Base.configurations
		our_backup_filename = "#{Rails.root}/data/helpdesk_tickets.sql.dump"
		
		if(abcs[RAILS_ENV]['password'].blank?)
				restore_command =  "mysql #{abcs[RAILS_ENV]['database']} -u #{abcs[RAILS_ENV]['username']} < #{our_backup_filename}"
			else
				restore_command =  "mysql #{abcs[RAILS_ENV]['database']} -u #{abcs[RAILS_ENV]['username']} -p#{abcs[RAILS_ENV]['password']} < #{our_backup_filename}"
			end
			puts "Restoring tickets using command:"
			puts "#{restore_command}"
			system restore_command
			
			puts "Removing Backup file: #{our_backup_filename}"
			system "rm #{our_backup_filename}"
			
  end
  
  
end
