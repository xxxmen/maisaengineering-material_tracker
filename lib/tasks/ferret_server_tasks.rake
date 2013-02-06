namespace :ferret do
    desc "Starts the ferret server for Newmans MTR."
    task :start => :environment do
       exec "sudo ruby #{Rails.root}/script/ferret_server start -e production --root=#{Rails.root}"
    end

    desc "Stops the ferret server for Newmans MTR."
    task :stop => :environment do
       exec "sudo ruby #{Rails.root}/script/ferret_server stop -e production --root=#{Rails.root}"
    end
end

