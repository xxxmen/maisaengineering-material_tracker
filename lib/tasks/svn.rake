namespace "svn" do
  desc "Configure Subversion for Rails"
  task :configure do
        
    # The following plugins will be imported by piston
    plugins_to_import = {
      :simply_helpful => "http://dev.rubyonrails.org/svn/rails/plugins/simply_helpful/",
      :memory_test_fix => "http://topfunky.net/svn/plugins/memory_test_fix/",
      :restful_authentication => "http://svn.techno-weenie.net/projects/plugins/restful_authentication/",
      :helper_test => "http://topfunky.net/svn/plugins/helper_test/",
      :interface_helper => "http://svn.t0fuu.com/rails/plugins/interface_helper"
      # :arts => "http://thar.be/svn/projects/plugins/arts/",
      # :acts_as_attachment => "http://svn.techno-weenie.net/projects/plugins/acts_as_attachment/"
    }
    
    # Commit everything before we do anything
    system "mkdir tmp/pids"
    system "svn add * --force"
    system "svn commit -m 'Commiting raw rails project'"
    
    # First, remove all unnecessary files and folders
    system "svn remove public/index.html --force"
    system "svn remove components --force"
    system "svn remove doc --force"
    system "svn remove log/* --force"
    system "svn remove tmp/cache/* --force"
    system "svn remove tmp/pids/* --force"
    system "svn remove tmp/sessions/* --force"
    system "svn remove tmp/sockets/* --force"
    system "svn commit -m 'removing all log and tmp files from subversion'"
  
    # Set svn:ignore on log directory
    system 'svn propset svn:ignore "*" log/'
    system "svn update log/"
    system "svn commit -m 'Ignoring all files in /log/ ending in .log'"
    
    # Set svn:ignore on db directory
    system 'svn propset svn:ignore "*.sqlite3
schema.rb" db/'
    system "svn update db/"
    system "svn commit -m 'Ignoring all files in /db/ ending in .db'"
        
    # Set svn:ignore on tmp directory
    system 'svn propset svn:ignore "*" tmp/cache'
    system "svn update tmp/"
    system 'svn propset svn:ignore "*" tmp/pids'
    system "svn update tmp/"
    system 'svn propset svn:ignore "*" tmp/sessions'
    system "svn update tmp/"
    system 'svn propset svn:ignore "*" tmp/sockets'
    system "svn update tmp/"
    system "svn commit -m 'Setting ignore on all files in /tmp folder'"
    
    # Set svn:ignore on current Rails.root
    system 'svn propset svn:ignore ".rake_tasks" .'
    system "svn commit -m 'Setting ignore on .rake_tasks for Rails.root.'"
  
    # Update Rails Javascript code
    system "rake rails:update"
    system "svn update"
    system "svn commit -m 'Updated Rails Javascript libraries'"
    
    # Import Edge Rails
    puts "== Importing Edge Rails, this may take a while. =="
    system "piston import http://dev.rubyonrails.org/svn/rails/trunk vendor/rails"
    system "svn commit -m 'Imported Edge Rails and updated all files.'"
    
    # Import the default plugins
    plugins_to_import.each do |name, repository|
      system "svn update"
      system "piston import #{repository.to_s} vendor/plugins/#{name.to_s}"
      system "svn commit -m 'Imported #{name.to_s}.'"
    end
    
    # Updating local sandbox
    system "svn update"
        
  end
end