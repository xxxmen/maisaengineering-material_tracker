module CsvFu
  module InstanceMethods; end
  module ClassMethods; end
  
  def self.write_file(path, content)
    f = File.new(path, "w+")
    f.puts content
    f.close
  end
  
  # Deletes all the table rows and then resets the primary key
  def self.reset_table(ar_class, connection)
    ar_class.destroy_all
    connection.execute("TRUNCATE TABLE #{ar_class.table_name}") if connection.class.is_a?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
  end
  
  # Takes a CSV string and creates new records for it
  def self.create_from_csv(ar_class, csv)
    rows = FasterCSV.parse(csv)
    header = rows.delete_at(0)
    
    ActiveRecord::Base.lock_optimistically = false
    rows.each do |row|
      record = ar_class.new
      header.each_with_index { |a, i| record.send(a.to_s + "=", row[i]) }
      record.save!
    end
  end
end

# Will be added as class methods to AR::Base
module CsvFu::ClassMethods
  # Returns a string in CSV format
  def to_csv
    find(:all).to_csv
  end
  
  def dump_to_file(path = nil)
    path ||= "#{RAILS_ROOT}/db/#{table_name}.csv"
    CsvFu.write_file(path, self.to_csv)
  end
  
  def load_from_file(path = nil)
    path ||= "#{RAILS_ROOT}/db/#{table_name}.csv"      
    CsvFu.reset_table(self, self.connection)
    
    csv = IO.read(path)
    CsvFu.create_from_csv(self, csv)
    
    # CsvFu.reset_table(self, self.connection, :only => :primary_key)
  end
end

# Will be added as instance methods to AR::Base
module CsvFu::InstanceMethods
  # Returns an array of values for each AR object
  def to_row(format = nil)
    self.class.column_names.map { |c| self.send(c) }
  end
end

# Extend Array to handle an array of AR objects
class Array
  def to_csv(options = {})
    # If the array is filled with AR objects, parse its attributes
    if self.length == 0
      ""
    elsif all? { |e| e.respond_to?(:to_row) }
      header_row = first.class.column_names.to_csv
      content_rows = map { |e| e.to_row }.map { |r| r.to_csv }
      ([header_row] + content_rows).join
    else
      FasterCSV.generate_line(self, options)
    end
  end
end