# Custom tasks to make working with sphinx easier
# Basically, thinking_sphinx's rake tasks balk if:
# 	a) You are trying to start a running process
#	b) You are trying to stop a non-existent process
# My custom tasks bypass those Exceptions.

namespace :thinking_sphinx do
	namespace :custom do
		desc "Starts searchd or does nothing if already running."
		task :start => :app_env do
			if sphinx_running?
				puts "Material Tracker Sphinx: searchd is already running (PID: #{sphinx_pid})"
			else
				Rake::Task["thinking_sphinx:start"].invoke
			end

		end

		desc "Stop Sphinx gracefully or does nothing if not running"
		task :stop => :app_env do
		unless sphinx_running?
				puts "Material Tracker Sphinx: searchd is not running." 
			else
				Rake::Task["thinking_sphinx:stop"].invoke
			end
		end

		desc "Restart Sphinx"
		task :restart => [:app_env, :stop, :start]
		
		desc "Stop Sphinx (if it's running), rebuild the indexes, and start Sphinx"
		task :rebuild => :app_env do
#			ENV["INDEX_ONLY"] = "true"
			Rake::Task["thinking_sphinx:custom:stop"].invoke
    		Rake::Task["thinking_sphinx:index"].invoke
    		Rake::Task["thinking_sphinx:custom:start"].invoke
		end
	end
end
