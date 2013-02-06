class Number < ActiveRecord::Base
end

class RemigrateNumbersAndRecentDateRange < ActiveRecord::Migration
  	def self.up
  		drop_table :numbers
	    create_table "numbers" do |t|
	    end
	    
	    # Create 30 static numbers in the database (1-30) for reports.
	    30.times do |number|
	      Number.create
	    end
	    
	    sql_string = ''
		File.open(File.join(Rails.root, 'db', 'recent_date_range.sql'), 'r') do |f|
			sql_string = f.read
		end
		@conn = ActiveRecord::Base.connection
		@conn.execute("DROP TABLE IF EXISTS `recent_date_range`;")
		@conn.execute("DROP VIEW IF EXISTS `recent_date_range`;")
		@conn.execute(sql_string)
  	end

  	def self.down
  	end
end
