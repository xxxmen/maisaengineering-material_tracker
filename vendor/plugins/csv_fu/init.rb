require File.dirname(__FILE__) + "/lib/csv_fu"

ActiveRecord::Base.send(:extend, CsvFu::ClassMethods)
ActiveRecord::Base.send(:include, CsvFu::InstanceMethods)