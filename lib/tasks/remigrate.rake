namespace "db" do
  desc "Drop then recreate the dev database, migrate up, and load fixtures" 
  task :remigrate => :environment do
    return unless %w[development production test staging].include? RAILS_ENV
    ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.drop_table t }
    Rake::Task[:migrate].invoke
    
    Vendor.find(:all).each {|v| LogEdit.create(:loggable => v)}
  end
end
