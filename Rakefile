# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

# Sphinx Tasks
begin
  require 'thinking_sphinx/tasks'
  require 'thinking_sphinx/deltas/datetime_delta/tasks'
rescue LoadError => e
  puts e
  puts "You need to 'gem install thinking-sphinx' and 'gem install ts-datetime-delta' buddy!"
end

# Vlad for deployment
begin
  require 'vlad'
  Vlad.load({:config => 'config/deploy/deploy.rb'})
rescue LoadError => e
  puts e
  puts "You need to 'sudo gem install vlad' buddy!"
end


MaterialTracker::Application.load_tasks