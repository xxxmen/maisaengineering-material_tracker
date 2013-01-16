# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

# Sphinx Tasks
begin
    require 'thinking_sphinx/tasks'
    require 'thinking_sphinx/deltas/datetime_delta/tasks'
rescue LoadError => e
    puts e
    puts "You need to 'gem install thinking-sphinx' and 'gem install ts-datetime-delta' buddy!"
end

begin
	require 'vlad'
	Vlad.load({:config => 'config/deploy/deploy.rb'})
rescue LoadError => e
	puts e
	puts "You need to 'sudo gem install vlad' buddy!"
end


