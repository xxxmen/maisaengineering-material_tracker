namespace :data do 
	namespace :load do
		desc "Loads the BP Cherrypoint Manufacturers"
		task :manufacturers => :environment do
			manufacturers = ""
	  		manufacturers_file = "#{Rails.root}/db/data_files/bpcherrypoint_manufacturers.csv"
	  		File.open(manufacturers_file, 'r') do |f|
	  			manufacturers = f.read	
  			end
	  		csv = FasterCSV.parse(manufacturers, :headers => :first_row)
	  		Manufacturer.transaction do
		  		csv.each do |row|
		  			row = row[0].strip
		  			Manufacturer.create!(:name => row)
		  			puts "Creating Manufacturer: #{row}"
	  			end
			end
	 	end
	 	
	 
 	end 
 	
 	namespace :delete do
		task :manufacturers => :environment do
			print "Delete all Manufacturers? "
			answer = STDIN.gets.strip.downcase
			if answer == "y" || answer == "yes"
				Manufacturer.delete_all
				puts "All deleted!"			
			else
				puts "Not deleting!"
			end
	 	end
	end 	 	
end
