namespace :vlad do

  desc "Copy the CP Production data to Staging"
  task :bpcp_staging_copy => :environment do
    Rake::Task['bpcp_production'].invoke
    run "echo Test Running this on Production"
    run "pwd"
    puts "#{deploy_site_name}"
  end
  desc "Copy the Carson Production data to Staging"
  task :bpcarson_staging_copy => :environment do

  end
end