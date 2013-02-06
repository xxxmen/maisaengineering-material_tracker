namespace :popv do

	desc "Do the data import for BP Carson"
	task :import_carson => :environment do

		ENV['POPV_DB_NAME'] = "#{ActiveRecord::Base.configurations[RAILS_ENV]['database']}"
		ENV['FIXTURES_LOCATION'] = "popv_carson"
		load "#{Rails.root}/data/scripts/popv_data_import.rb"
		POPVImportData.up
	end

	desc "Do the data import for BP Cherry Point"
	task :import_bpcherrypoint => :environment do
		
		ENV['POPV_DB_NAME'] = "#{ActiveRecord::Base.configurations[RAILS_ENV]['database']}"
		ENV['FIXTURES_LOCATION'] = "popv_bpcherrypoint"
		load "#{Rails.root}/data/scripts/popv_data_import.rb"
		POPVImportData.up
	end
	
	desc "Import Revision History from BP Cherrypoint"
	task :import_history_from_bpcp => :environment do
		ENV['POPV_DB_NAME'] = "#{ActiveRecord::Base.configurations[RAILS_ENV]['database']}"
		ENV['FIXTURES_LOCATION'] = "popv_bpcherrypoint"
		load "#{Rails.root}/data/scripts/import_revision_history.rb"
		POPVImportRevisionHistory.up
	end
	
	desc "Create the Piping Subcomponents (BPCherrypoint)"
	task :create_subcomponents_cherrypoint => :environment do
		@fitting_subcomponents = [
		    "45 DEG ELBOW",
		    "90 DEG ELBOW",
		    "90 DEG REDUCING ELBOW",
		    "45 DEG 3D ELBOW",
		    "90 DEG 3D ELBOW",
		    "CAP",
		    "COUPLING",
		    "CROSS",
		    "STRAIGHT TEE",
		    "REDUCING TEE",
		    "CONCENTRIC REDUCER",
		    "ECCENTRIC REDUCER",
		    "CONCENTRIC SWAGED NIPPLE",
		    "ECCENTRIC SWAGED NIPPLE",
		    "90 DEG SHORT RADIUS ELBOW"
		]

		@branch_connection_subcomponents = [
		    "SOCKETWELD PIPET",
		    "BUTTWELD PIPET",
		    "THREADED PIPET",
		    "BUTTWELD ELBO PIPET",
		    "SOCKETWELD ELBO PIPET",
		    "THREADED ELBO PIPET",
		    "BUTTWELD LATERAL PIPET",
		    "SOCKETWELD LATERAL PIPET",
		    "THREADED LATERAL PIPET",
		    "THREADED NIPPLE PIPET",
		    "PLAIN END NIPPLE PIPET",
		    "FLANGED PIPET"
		]

		ENV['POPV_DB_NAME'] = "#{ActiveRecord::Base.configurations[RAILS_ENV]['database']}"
		
		
		load "#{Rails.root}/data/scripts/create_subcomponents.rb"
	end
	
	desc "Create the Piping Subcomponents (BPCarson)"
	task :create_subcomponents_bpcarson => :environment do
		@fitting_subcomponents = [
              '45 DEG ELBOW',
              '90 DEG ELBOW',
              '90 DEG REDUCING ELBOW',
              'CAP',
              'COUPLNG',
              'CROSS',
              'TEE',
              'REDUCER',
              'REDUCING TEE',
              'CONCENTRIC REDUCER',
              'ECCENTRIC REDUCER',
              'SWAGE',
              'ELBOW',
              'SHORT RADIUS ELBOW',
              'REDUCING ELBOW']
        
		@branch_connection_subcomponents = [
							'SOCKETWELD ELBO PIPET', 
							'THREADED ELBO PIPET',
							'BUTTWELD ELBO PIPET',
							'THREADED PIPET',
							'SOCKETWELD PIPET', 
							'BUTTWELD PIPET',
							'BUTTWELD LATERAL PIPET', 
							'SOCKETWELD LATERAL PIPET', 
							'THREADED LATERAL PIPET',
							'THREADED NIPPLE PIPET',
							'PLAIN END NIPPLE PIPET',
							'FLANGED PIPET']
		ENV['POPV_DB_NAME'] = "#{ActiveRecord::Base.configurations[RAILS_ENV]['database']}"
		
		
		load "#{Rails.root}/data/scripts/create_subcomponents.rb"
		
		
	end
end
