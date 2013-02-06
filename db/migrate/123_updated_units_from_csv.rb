class UpdatedUnitsFromCsv < ActiveRecord::Migration
  def self.up
      execute "DELETE FROM units"
      if (Rails.env.development? && RUBY_PLATFORM =~ /i686-linux/)
          execute "LOAD DATA INFILE '/tmp/complete_list_of_units.csv' INTO TABLE units FIELDS TERMINATED BY ',' ENCLOSED BY '\"' IGNORE 1 LINES;"     
      else
          execute "LOAD DATA INFILE '#{Rails.root}/db/data_files/complete_list_of_units.csv' INTO TABLE units FIELDS TERMINATED BY ',' ENCLOSED BY '\"' IGNORE 1 LINES;"
      end
      [Bill, Cart, MaterialRequest, Order].each do |klass|
          records = klass.find(:all, :conditions => ["unit_id = ?", 97])
          puts klass
          puts records.size
          records.each do |r|
            r.unit_id = 95
            r.save!
          end
      end
      
  end

  def self.down
  end
end
