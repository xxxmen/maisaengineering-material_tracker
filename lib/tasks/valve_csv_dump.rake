# Created by: Adam Grant
# Created on: 2009-11-24
#
# Utility methods for dumping Valve data to CSV format.

namespace :popv do

	# Dumps the valves into a file specified by VALVES_DUMP_PATH so BP can compare
	# against their internal set.
	desc "Dumps all the valves and components to a CSV"
	task :dump_valves => :environment do
		
		VALVES_DUMP_PATH = File.join(RAILS_ROOT, "tmp", "valves_dump.csv")
		
		begin
			require 'fastercsv'
		rescue LoadError
			puts "To dump the valves CSV, you must first 'sudo gem install fastercsv'"
			return
		end
		
		puts "Starting Valve Dump..."
		
		@starting_headers = [
			"valve_code", "valve_note", "valve_body", "valve_rating", 
			"valve_type", "discontinued", "manufacturers_remarks", "archived"
		]
		
		@headers = @starting_headers.dup
		
		# Don't include body, rating, or type since these components since they 
		# were moved to the valves table.
		@valve_components = ValveComponent.find(:all, 
			:order => 'component_name ASC',
			:conditions => ['component_name NOT LIKE ? AND component_name NOT LIKE ? AND component_name NOT LIKE ?',
				'BODY', 'RATING', 'TYPE'
			]
		)
		
		@valve_components.each do |valve_comp|
			name = valve_comp.component_name
			@headers << "#{name}"
		end
		
		@valves = Valve.find(:all, :order => 'valve_code ASC')
		
		faster_csv_options = { 
			:col_sep => ',', 
			:quote_char => '"', 
			:headers => @headers, 
			:write_headers => true
		}
		
		csv_string = FasterCSV.generate(faster_csv_options) do |csv|
			@valves.each do |valve|
				puts "Valve: #{valve.valve_code}"
				new_csv_row = []
				@starting_headers.each do |header|
					new_csv_row << valve.send(:"#{header}")
				end
				
				@valve_components.each do |comp|
					comp_id = comp.id
					valve_comp = valve.valves_valve_components.find(:first, :conditions => ['valve_component_id = ?', comp_id])
					if valve_comp.present?
						new_csv_row << valve_comp.component_text
					else
						new_csv_row << ''
					end
				end
				
				csv << new_csv_row
			end		
		end
		
		File.open(VALVES_DUMP_PATH, 'w') do |file|
			file.write csv_string	
		end
	end
	
	# Dumps the manufacturers of valves and their associated figure no's into a 
	# file specified by MANUFACTURERS_VALVES_DUMP_PATH so BP can compare
	# against their internal set.
	task :dump_valve_manufacturers => :environment do

		MANUFACTURERS_VALVES_DUMP_PATH = File.join(RAILS_ROOT, "tmp", "manufacturers_valves_dump.csv")
		
		begin
			require 'fastercsv'
		rescue LoadError
			puts "To dump the valves CSV, you must first 'sudo gem install fastercsv'"
			return
		end

		
		@headers = ['valve_code', 'manufacturer', 'figure_no', 'valve_id', 'manufacturer_id', 'manufacturers_valves_id']
		faster_csv_options = { 
			:col_sep => ',', 
			:quote_char => '"', 
			:headers => @headers, 
			:write_headers => true
		}
		
		@valves = Valve.find(:all)
		
		csv_string = FasterCSV.generate(faster_csv_options) do |csv|			
			@valves.each do |valve|
				valve.manufacturers_valves.each do |mv|
					new_csv_row = []
					
					man = mv.manufacturer
					
					new_csv_row << valve.valve_code
					new_csv_row << man.name
					new_csv_row << mv.figure_no
					new_csv_row << valve.id
					new_csv_row << man.id
					new_csv_row << mv.id
					
					csv << new_csv_row
				end
			end
		end
		
		File.open(MANUFACTURERS_VALVES_DUMP_PATH, 'w') do |file|
			file.write csv_string	
		end
	end

end

