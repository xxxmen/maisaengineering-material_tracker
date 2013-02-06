require 'fastercsv'

class POPVImportRevisionHistory < ActiveRecord::Migration
	def self.up
		puts "This will import the BPCherrypoint Revision History CSV into the record_changelogs table. It will NOT erase any data before this happens (non-destructive). Be sure you cleaned up the record_changelogs table before running this! Are you sure you want to proceed? (Y/n)"
		response = STDIN.gets.chomp
		if response == 'Y' || response == 'y'
			RecordChangelog.enable_recording = false
			RecordChangelog.transaction do
				self.import_history
			end
		else
			puts "Fine, I'm quitting, I'm quitting! Jeez..."
		end
	end
	
	
	def self.import_history
		["Class_Code", "Rev_Date", "Piping_Comp_Name", "Rev_Desc", "Last_Updt_Id", "Last_Updt_Date"]
		filepath = File.join(Rails.root, 'data', 'csvs', 'popv_bpcherrypoint', 'Revision_History.csv')
		csv = FasterCSV.open(filepath, {:headers => true, :force_quotes => true})
		i = 1
		csv.each do |row|
			puts "Parsing row #{i}..."
			class_code = row["Class_Code"].to_s.strip
			rev_date = row["Rev_Date"].to_s.strip
			comp_name = row["Piping_Comp_Name"].to_s.strip
			comment = row["Rev_Desc"].to_s.strip
			modified_by = row["Last_Updt_Id"].to_s.strip
			alternative_rev_date = row["Last_Updt_Date"].to_s.strip
			
			if rev_date.blank?
				rev_date = alternative_rev_date
			end
			
			begin
				modified_at = Date.parse(rev_date)
			rescue ArgumentError
				puts "Could not parse these dates: #{rev_date} #{alternative_rev_date}"
			end
			
			changelog = RecordChangelog.new
			
			if comp_name.blank?
				changelog.record_type = 'Piping Class'
				changelog.action = 'Updated'
				changelog.record_identifier = class_code
			else
				changelog.record_type = 'Piping Detail'
				changelog.action = 'Updated'
				changelog.record_identifier = "#{class_code} - #{comp_name}"
			end
			
			changelog.comment = comment
			changelog.modified_at = modified_at
			changelog.modified_by = modified_by
			
			changelog.save!
			i += 1
		end
	end
end

#  create_table "record_changelogs", :force => true do |t|
#    t.string   "record_type"
#    t.string   "field_name"
#    t.text     "old_value"
#    t.text     "new_value"
#    t.datetime "modified_at"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.string   "record_identifier"
#    t.string   "action"
#    t.string   "modified_by"
#    t.text     "comment"
#  end

