namespace :ferret do
    desc "Starts the ferret server for Newmans MTR."
    task :start => :environment do
       exec "sudo ruby #{RAILS_ROOT}/script/ferret_server start -e production --root=#{RAILS_ROOT}"
    end

    desc "Stops the ferret server for Newmans MTR."
    task :stop => :environment do
       exec "sudo ruby #{RAILS_ROOT}/script/ferret_server stop -e production --root=#{RAILS_ROOT}"
    end
end

