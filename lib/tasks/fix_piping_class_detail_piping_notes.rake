namespace :popv do
    namespace :bpcherrypoint do
        task :fix_piping_class_detail_piping_notes => :environment do
           	ENV['POPV_DB_NAME'] = "#{ActiveRecord::Base.configurations[RAILS_ENV]['database']}"
    		ENV['FIXTURES_LOCATION'] = "popv_bpcherrypoint"
    		load "#{Rails.root}/data/scripts/popv_data_import.rb"
    		POPVImportData.update_piping_notes_for_piping_class_details	 
        end
    end
end