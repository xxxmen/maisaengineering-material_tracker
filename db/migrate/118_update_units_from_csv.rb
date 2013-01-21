class UpdateUnitsFromCsv < ActiveRecord::Migration
  def self.up
      execute "DELETE FROM units"
      if (RAILS_ENV == 'development' && RUBY_PLATFORM =~ /i686-linux/)
          execute "LOAD DATA INFILE '/tmp/complete_list_of_units.csv' INTO TABLE units FIELDS TERMINATED BY ',' ENCLOSED BY '\"' IGNORE 1 LINES;"     
      else
          execute "LOAD DATA INFILE '#{RAILS_ROOT}/db/data_files/complete_list_of_units.csv' INTO TABLE units FIELDS TERMINATED BY ',' ENCLOSED BY '\"' IGNORE 1 LINES;"
      end      
  end

  def self.down
  end
end
