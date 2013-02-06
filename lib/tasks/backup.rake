namespace :db do
	#Purpose 
	#To backup any production database to an off-site location
	
	#Assumptions
	#You're using a MYSQL server, and that the user has admin priveleges.
	#Your config/database.yml file is set up correctly.
	
	#Actions
	#Use mysqldump to create a dumpfile of the database
	#Zip that file using gzip
	#Build an FTP batch file for sending the zip and removing backup from 31 days past
	#Send zip to sftp server into directory
	#Clean up zip/dump/ftp batch file
	#
	
	#Arguemts
	#This rakefile can be called from the Rails.root location of your server
	#To manually call this file, do something like:
	#rake db:send_backup RAILS_ENV=production SERVER_LOCATION="root@backupserver.com"
	
	#Setup
	#Step 1
	#Make sure the public key for the production server is in the authorized_keys or
	#authorized_keys2 file located on the sftp server
	#Make sure you create a directory on the SFTP server root for the database name.  
	#     This is the location the zip files will end up in
	#
	#Step 2
	#Load this rake task into Rails.root/lib/tasks
	#
	#Step 3
	#Set up a crontab similar to the following to run the rake task daily at 3am
	#
	#MAILTO=""
	#* 3 * * * /usr/local/bin/rake db:send_backup RAILS_ENV=production -f /home/applications/newmans/Rakefile Rails.root=/home/applications/YOURAPPLICATION SERVER_LOCATION=YOURUSER@YOURROOT
	# 
	#
	#

	desc "Create a backup and send via SFTP to a backup server"
	task :send_backup do	
		if(Rails.env.production?)
			load Rails.root + '/config/environment.rb'
			timenow = Time.now
			abcs = ActiveRecord::Base.configurations
			our_backup_filename = "#{abcs[RAILS_ENV]['database']}.#{timenow.month}.#{timenow.day}.#{timenow.year}.dump"
			our_backup_zipname = "#{abcs[RAILS_ENV]['database']}.#{timenow.month}.#{timenow.day}.#{timenow.year}.zip"
			
			if(abcs[RAILS_ENV]['password'] == "")
				system "mysqldump #{abcs[RAILS_ENV]['database']} -u #{abcs[RAILS_ENV]['username']} >> #{abcs[RAILS_ENV]['database']}.#{timenow.month}.#{timenow.day}.#{timenow.year}.dump"
			else
				system "mysqldump #{abcs[RAILS_ENV]['database']} -u #{abcs[RAILS_ENV]['username']} -p#{abcs[RAILS_ENV]['password']} >> #{our_backup_filename}"
			end
			
			system "gzip -c #{our_backup_filename} >> #{our_backup_zipname}"
			system "rm -f #{our_backup_filename}"
			
			#now, our file is on the server. 
			#we want to build an ftp batch file to remove the backup from 31 days ago
			time_a_month_ago = Time.now - 31.days
			our_old_backup_zipname = "#{abcs[RAILS_ENV]['database']}.#{time_a_month_ago.month}.#{time_a_month_ago.day}.#{time_a_month_ago.year}.zip"
			data = "put #{our_backup_zipname} #{abcs[RAILS_ENV]['database']}/#{our_backup_zipname}\r\n"
			data += "rm #{abcs[RAILS_ENV]['database']}/#{our_old_backup_zipname}"
			File.open(Rails.root + "/ftp_send_current.ftp",  "w+") do  |f|
				f.write(data)
			end
			system "sftp -b #{Rails.root + "/ftp_send_current.ftp"} #{ENV['SERVER_LOCATION']}"
			
			#clean up the zipfile + ftp batch file
			system "rm -f #{our_backup_zipname}"
			system "rm -f #{Rails.root + "/ftp_send_current.ftp"}"
		end
	end
	
	# Creates a backup of your db at "~/sqls/#{db_name}/#{db_name}.#{Date}.sql"
	desc "Create a backup of the RAILS_ENV db to local folder."
	task :backup => :environment do
		RAILS_ENV ||= "development"
		
		db_config = ActiveRecord::Base.configurations[RAILS_ENV]
		
		user = db_config["username"]
		password = db_config["password"]
		db = db_config["database"]
		
		file_name = "#{db}.#{Date.today.to_formatted_s(:db)}.sql"
		directory_path = File.join(File.expand_path("~"), "sqls", db)
		full_path = File.join(directory_path, file_name)
		
		FileUtils.mkdir_p(directory_path)

		command = "mysqldump -u #{user} -p#{password} #{db} > #{full_path}"
		puts "Executing mysqldump command...\n> #{command}"
		system command
	end
end
