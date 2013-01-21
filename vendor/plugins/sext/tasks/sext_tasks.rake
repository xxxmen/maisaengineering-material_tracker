# Usage:
# rake ext:resources RESOURCES=users,companies,vehicles
#

module SextTask
  def self.grid_field_for(col, klass)
    if col.type == :datetime || col.type == :date
      "{id: '#{col.name}', renderer: telaeris.util.dateFormat}"
    elsif col.type == :boolean
      "{id: '#{col.name}', renderer: telaeris.util.boolFormat}"
    else
      "'#{col.name}'"  
    end
  end

  def self.form_field_for(col, klass)
    if col.type == :datetime || col.type == :date
      "{ xtype: 'datefield', name: '#{col.name}' }"
    elsif col.type == :text
      "{ xtype: 'textarea', name: '#{col.name}' }"
    elsif col.type == :boolean
      "{ xtype: 'checkbox', name: '#{col.name}' }"
	elsif col.type == :binary
	  "{fieldLabel:'#{col.name.gsub('_',' ').titleize}', name:'#{col.name}', inputType: 'file'}"
    else
      "'#{col.name}'"
    end
  end

  
  def self.warn_user_of_id_for_nice_name(file_name, relation_name)
    return "WARNING: The Field 'id' was used instead of an actual field. This can be fixed by editing the relation '#{relation_name}' in '#{file_name}'."
  end
  
  def self.js_resource_for(klass)
    resource = klass.to_s.underscore.pluralize
    grid_class_columns = klass.columns.dup
    form_class_columns = klass.columns.dup
    js_grid_fields = grid_class_columns.delete_if { |c| c.type == :binary || c.name == "id" || c.name =~ /_id$/ || c.name == "updated_at" || c.name == "created_at" }
    js_grid_fields = js_grid_fields.map { |c| SextTask.grid_field_for(c, klass) }.join(",\n            ")
    
    js_form_fields = form_class_columns.delete_if { |c| c.name == "id" || c.name =~ /_id$/ || c.name == "updated_at" || c.name == "created_at" }
    binary_exists = false
    js_form_fields.each do |this_form_field|
		if(this_form_field.type == :binary)
			binary_exists = true
		end
	end
	
	
    
    js_form_fields = js_form_fields.map { |c| SextTask.form_field_for(c, klass) }
    js_form_fields = js_form_fields + klass.reflect_on_all_associations(:belongs_to).map do |assoc|
      name = assoc.name
      key = assoc.primary_key_name
      assoc_column_name = Sext.associated_column_nice_name(assoc.name.to_s.camelcase)
      url = "/sext/#{name.to_s.pluralize}/store/id"
      
      "{ xtype: 'combo', name: '#{key}', displayField: '#{assoc_column_name}',valueField: 'id', url: '#{url}' }"
    end
    js_form_fields = js_form_fields.join(",\n            ")
    
    js_resource = "telaeris.resources({\n"
    js_resource += "    #{resource}: {\n"
    js_resource += "        gridFields: [\n            #{js_grid_fields}\n        ],\n"
    js_resource += "        formConfig: {fileUpload:true},\n" if(binary_exists)
    js_resource += "        formFields: [\n            #{js_form_fields}\n        ]\n"
    js_resource += "    }\n"
    js_resource += "});\n"
    return js_resource
  end
  
  def self.js_habtm_for(klass)
    klass.reflect_on_all_associations(:has_and_belongs_to_many).map do |assoc|
      resource = klass.to_s.underscore.pluralize.to_s
      assoc_name = assoc.name.to_s
      
      # alphabetize the relationship (animals_users is the correct order NOT users_animals)
      #window_name = assoc_name < resource ? assoc_name + "_" + resource : resource + "_" + assoc_name
      window_name = resource + "_" + assoc_name
      
      # get the key names
      primary_key = assoc.primary_key_name
      foreign_key = assoc.association_foreign_key
      
      # get the urls
      primary_url = "/sext/#{resource}/store/id"
      foreign_url = "/sext/#{assoc_name}/store/id"
      primary_nice_name = Sext.associated_column_nice_name(resource.singularize.camelcase)
      foreign_nice_name = Sext.associated_column_nice_name(assoc_name.singularize.camelcase)
      
      js_resource = "telaeris.windows({\n"
      js_resource += "    '#{window_name}': {\n"
      js_resource += "        url: '/sext/#{resource}/add/#{assoc_name}',\n"
      js_resource += "        formFields: [\n"
      if(primary_nice_name == 'id')
        js_resource += "//Note, the displayField for '#{primary_key}' is currently set to ID.  This may not be desired\n"
      end
      js_resource += "            { xtype: 'combo', name: '#{primary_key}', displayField: '#{primary_nice_name}', url: '#{primary_url}', autoLoad: true },\n"
      if(foreign_nice_name == 'id')
        js_resource += "//Note, the displayField for '#{foreign_key}' is currently set to ID.  This may not be desired\n"
      end
      js_resource += "            { xtype: 'combo', name: '#{foreign_key}', displayField: '#{foreign_nice_name}', url: '#{foreign_url}', autoLoad: false }\n"
      js_resource += "        ],\n"
      js_resource += "        success: function(){\n"
      js_resource += "                 if(Ext.getCmp('#{resource}_form')){\n"
      js_resource += "                   var idValue = Ext.getCmp('#{resource}_form').getForm().getValues()['id'];\n"
      js_resource += "                   telaeris.editRecordFromURL('#{resource}', '/sext/#{resource}/' + idValue);\n"
      js_resource += "                 }\n"
      js_resource += "                 if(Ext.getCmp('#{resource}_grid')){\n"
      js_resource += "                   Ext.getCmp('#{resource}_grid').store.load();\n"
      js_resource += "                 }\n"
      js_resource += "                 if(Ext.getCmp('#{assoc_name}_grid')){\n"
      js_resource += "                 Ext.getCmp('#{assoc_name}_grid').store.load();\n"
      js_resource += "                 }\n"
      js_resource += "                 Ext.getCmp('#{window_name}_window').hide();\n"
      js_resource += "        },\n"
      js_resource += "        onShow: function(){\n"
      js_resource += "                   if(Ext.getCmp('#{resource}_form')){\n"
	  js_resource += "                     var idValue = Ext.getCmp('#{resource}_form').getForm().getValues()['id'];\n"
	  js_resource += "                     Ext.getCmp('#{window_name}_form').getForm().setValues([{id: '#{resource.singularize}_id', value:idValue}]);\n"
	  js_resource += "                   }\n"
	  js_resource += "                 }\n"
      js_resource += "        }\n"
      js_resource += "});\n"
    end
  end

  # path is relative from RAILS_ROOT without the first slash
  def self.generate_source(path)
    abs_path = RAILS_ROOT + "/" + path
    if File.exists?(abs_path)
      puts "File exists, failed to generate: #{path}"
      return
    else
      File.open(abs_path, "w") do |f|
        yield f
      end
      puts "Generated new file: #{path}"
    end
  end
end

namespace :sext do
  desc "Generates the resources.js file for an ext application"
  task :js => :environment do
    resources = ENV['RESOURCE'].split(',')
    # open STDOUT or a file
        if ENV.has_key?('FILE')
          filename = ENV['FILE'] == 'true' ? 'public/javascripts/resources.js' : ENV['FILE']
          out = File.open(filename, 'a')
        else
          out = STDOUT
        end
        
    resources.each do |resource|    
        klass = Module.const_get(resource.singularize.camelcase)
        
        out.puts ""
        out.puts SextTask.js_resource_for(klass)   
        out.puts "" 
        out.puts SextTask.js_habtm_for(klass)
        out.puts ""
    end
    
    out.close unless out == STDOUT
  end  
  
  desc "Adds a user to the db"
  task :add_user => :environment do
    fields = {}
    field_inputs = ENV['FIELDS'].split(/ +/)
    field_inputs.each do |input|
      name, value = input.split(':')
      fields[name.to_sym] = value
    end
    
    user = User.new(:first_name => fields[:first_name], :last_name => fields[:last_name], :password => fields[:password], :password_confirmation => fields[:password], :email => fields[:email], :login => fields[:login])
    if user.valid?
      user.save!
    else
      puts user.errors.full_messages.join("\n")
    end
  end
  
  desc "Generates stub files for migration, model, controller, and spec"
  task :resource => :environment do
    # rake sext:resource RESOURCE=users FIELDS="first_name:string last_name:string company_id:integer" ASSOCIATIONS="belongs_to:company"
    resource = ENV['RESOURCE']   # UsersController, users_controller.rb, User, user.rb
    resource_single = resource.singularize.underscore
    resource_plural = resource_single.pluralize.underscore
    
    fields = {}
    file_fields = []
    field_inputs = ENV.has_key?('FIELDS') ? ENV['FIELDS'].split(/ +/) : []
    field_inputs.each do |field|
      name, value = field.split(':')
      fields[name] = value
      if(value == 'file')
      	file_fields << name
  	  end
    end
    
    associations = {
      :has_many => [],
      :belongs_to => [],
      :has_and_belongs_to_many => [],
    }
    association_inputs = ENV.has_key?('ASSOCIATIONS') ? ENV['ASSOCIATIONS'].split(/ +/) : []
    association_inputs.each do |field|
      association_type, association_name = field.split(':')
      association_type = :has_and_belongs_to_many if association_type.to_sym == :habtm
      associations[association_type.to_sym].push(association_name) if associations.has_key?(association_type.to_sym)
    end
    
    SextTask.generate_source("app/models/#{resource_single}.rb") do |f|
	    f.puts "class #{resource_single.camelcase} < ActiveRecord::Base"
	      associations[:has_many].each { |name| f.puts "  has_many :#{name}" }
	      associations[:belongs_to].each { |name| f.puts "  belongs_to :#{name}" }
	      associations[:has_and_belongs_to_many].each { |name| f.puts "  has_and_belongs_to_many :#{name}" }
	      if associations[:has_and_belongs_to_many].size > 0 || associations[:belongs_to].size > 0
	        f.puts ""
	        f.puts "  def sext_related_data"
	        f.puts "    related_data = []"
	        if(file_fields.length > 0)
	        	file_fields.each do |file_field|
	        		field_title = file_field.singularize.gsub('_',' ').titleize
		        	f.puts "    if(self.#{file_field})"
	      			f.puts "      secondary = []"
	      			f.puts "      secondary << { :label => \"#{field_title}\", :command => \"window.open\", :args => \"/#{resource_plural}/#{resource_plural}/#{file_field}/\#{self.id}\"}"
	      			f.puts "      related_data << { :label => '#{field_title}', :value => 'Download', :secondary => secondary }"
					f.puts "    end"
				end
	        end
	        
	        associations[:has_many].each do |name|
	          nice_name = Sext.associated_column_nice_name(name.singularize.camelcase)
	          title = name.gsub(/_/, ' ').capitalize
	          f.puts "    self.#{name}.each do |row|"
	          f.puts "      related_data << { :label => '#{title}', :value => row.#{nice_name} }"
	          
	          #Warn the user of the file and line number
	          if(nice_name == 'id')
	            puts SextTask.warn_user_of_id_for_nice_name("app/models/#{resource_single}.rb", name)
	          end
	          f.puts "    end"
	        end
	        associations[:has_and_belongs_to_many].each do |name|
	          # alphabetize the relationship (animals_users is the correct order NOT users_animals)
	          #name < resource_plural ? name + "_" + resource_plural : resource_plural + "_" + name
	          window_name = resource_plural + "_" + name
	          primary_key = resource_single + "_id"
              foreign_key = name.singularize.underscore + "_id"
	          title = name.gsub(/_/, ' ').capitalize
	          nice_name = Sext.associated_column_nice_name(name.singularize.camelcase)
	          
	          f.puts "    related_data << { :label => '#{title}', :value => 'Add #{title}', :command => 'telaeris.windows.#{window_name}.show'}"
	          f.puts "    self.#{name}.each do |row|"
	          f.puts "      secondary = []"
	          f.puts "      keys = {:#{primary_key} => self.id, :#{foreign_key}=> row.id, :resource_id => self.id}"
	          f.puts "      secondary << { :label => \"remove\", :command => \"application.removeAssociation\", :confirm => 'Are you sure you want to remove this association?', :args => { :resource => '#{resource_plural}', :association => '#{name}', :keys => keys }}"
	          
	          f.puts "      related_data << { :label => '#{title}', :value => row.#{nice_name}, :secondary => secondary }"	          
	          #Warn the user of the file and line number
	          if(nice_name == 'id')
	            puts SextTask.warn_user_of_id_for_nice_name("app/models/#{resource_single}.rb", name)
	          end
	          f.puts "    end"
	        end
	        associations[:belongs_to].each do |name|
	          title = name.gsub(/_/, ' ').capitalize
	          f.puts "    related_data << { :label => '#{title}', :value => self.#{name}_id, :command => 'telaeris.linkTo', :args => { :resource => '#{name}', :id => #{name}_id } }"
	        end
	        f.puts "    return related_data"
	        f.puts "  end\n"
	      end
	      f.puts "end"
    end
    
    SextTask.generate_source("app/controllers/#{resource_plural}_controller.rb") do |f|
      f.puts "class #{resource_plural.camelcase}Controller < SextController"
      f.puts "  def index"
      f.puts "    #Put your own code here which modifies the index action"
      f.puts "    #Make sure you have a route in routes such as:"
  	  f.puts "    # map.resources '#{resource_plural}', :path_prefix => 'sext/?resource=#{resource_plural}'"
      f.puts "    super()"
      f.puts "  end"
      if(file_fields.length > 0)
	     file_fields.each do |file_field|
	       f.puts "  def #{file_field}"
	       f.puts "    @#{resource_single} =  #{resource_single.camelcase}.find(params[:id])"
	       f.puts "    send_data(@#{resource_single}.#{file_field}, :disposition => 'inline')"
	       f.puts "  end"
  		 end
	  end
      f.puts "end"
    end
    
    # figure out which number migration it is now
    migrations = Dir.new(RAILS_ROOT + "/db/migrate").entries    
    migration_numbers = migrations.find_all { |f| f =~ /^\d\d\d/ }.map { |f| f.slice(0, 3).to_i }

    new_num_int = (migration_numbers.max || 0) + 1
    new_num = "%03d" % new_num_int
    
    #check if this migration exists
	migration_exists = false
	migrations.each do |migration|
		if(migration.include?("create_" + resource_plural + ".rb"))
			migration_exists = true
		end
	end
	if(migration_exists)
		puts "Migration for #{resource_plural} already exists"
	else
    	SextTask.generate_source("db/migrate/#{new_num}_create_#{resource_plural}.rb") do |f|
    	  f.puts "class Create#{resource_plural.camelcase} < ActiveRecord::Migration"
    	  f.puts "  def self.up"
    	  f.puts "    create_table :#{resource_plural} do |t|"
    	  fields.each do |key, value|
    	    f.puts "      t.string   :#{key}" if value == "string"
    	    f.puts "      t.text     :#{key}" if value == "text"
    	    f.puts "      t.date     :#{key}" if value == "date"
    	    f.puts "      t.datetime :#{key}" if value == "datetime"
    	    f.puts "      t.integer  :#{key}" if value == "integer" || value == "int"
    	    f.puts "      t.boolean  :#{key}" if value == "boolean"
    	    f.puts "      t.binary   :#{key}" if value == "file"
    	  end
    	  f.puts "      t.timestamps"
    	  f.puts "    end"
    	  f.puts "  end"
    	  f.puts ""
    	  f.puts "  def self.down"
    	  f.puts "    drop_table :#{resource_plural}"
    	  f.puts "  end"
    	  f.puts "end"
    	end
    end
    if associations[:has_and_belongs_to_many].size > 0
        associations[:has_and_belongs_to_many].each do |assoc_name|
          table_name = assoc_name < resource_plural ? assoc_name + "_" + resource_plural : resource_plural + "_" + assoc_name
              
    	  #check if this migration exists
          migration_exists = false
          migrations.each do |migration|
         	  if(migration.include?("create_" + table_name + ".rb"))
         	  	migration_exists = true
   	        end
  	      end
  	      if(migration_exists)
  	      	puts "Migration for #{table_name} already exists"
  	      else
              SextTask.generate_source("db/migrate/#{"%03d" % (new_num_int + 1)}_create_#{table_name}.rb") do |f|
              f.puts "class Create#{table_name.camelcase} < ActiveRecord::Migration"
                f.puts "  def self.up"
              primary_key = resource_single + "_id"
              foreign_key = assoc_name.singularize.underscore + "_id"
              f.puts "    create_table :#{table_name}, :id => false do |t|"
              f.puts "      t.integer  :#{primary_key}"
              f.puts "      t.integer  :#{foreign_key}"
              f.puts "    end"
              f.puts "    add_index :#{table_name},[:#{primary_key},:#{foreign_key}]"
              f.puts "  end"
              f.puts ""
              f.puts "  def self.down"
              f.puts "    remove_index :#{table_name},[:#{primary_key},:#{foreign_key}]"
              f.puts "    drop_table :#{table_name}"
              f.puts "  end"
              f.puts "end"
          end
        end
      end
    end
    
    # put inside routes.rb
    routes = IO.read('config/routes.rb')
    if routes !~ /map\.resources +:#{resource_plural}/
      routes = routes.sub("|map|\n", "|map|\n  map.resources :#{resource_plural}\n")
      puts "Appending '#{resource_plural}' to routes.rb"
      File.open('config/routes.rb', "w") do |f|
        f.puts routes
      end
    else
      puts "Resource '#{resource_plural}' already exists in routes.rb"
    end
    
    puts "1) run `rake db:migrate` to migration your db"
    puts "2) run `rake sext:js RESOURCE=#{resource_plural} FILE=true` for resources.js code"
  end
  
  desc "Bootstraps an Ext/Rails application with js, rb, and erb files"
  task :bootstrap => :environment do
    files = {
      # js: application.js, ext-all-debug.js, ext-all.js, ext-base.js, resources.js, telaeris.js    
      'public/javascripts/application.js' => 'js/application.js',
      'public/javascripts/ext-all-debug.js' => 'js/ext-all-debug.js',
      'public/javascripts/ext-all.js' => 'js/ext-all.js',
      'public/javascripts/ext-base.js' => 'js/ext-base.js',
      'public/javascripts/telaeris.js' => 'js/telaeris.js',
      'public/javascripts/resources.js' => 'js/resources.js',

      # rb: application.rb, sext_controller.rb, users_controller.rb, sessions_controller.rb, user.rb, create_users.rb, authenticated_system.rb, routes.rb
      'app/controllers/application.rb' => 'rb/application.rb',
      'app/controllers/sext_controller.rb' => 'rb/sext_controller.rb',
      'app/controllers/users_controller.rb' => 'rb/users_controller.rb',
      'app/controllers/sessions_controller.rb' => 'rb/sessions_controller.rb',
      'app/models/user.rb' => 'rb/user.rb',
      'db/migrate/001_create_users.rb' => 'rb/001_create_users.rb',
      'vendor/authenticated_system.rb' => 'rb/authenticated_system.rb',

      # css files and images/icons, ext-all.css, styles.css, xtheme-gray.css
      'public/images/default' => 'img/default',
      'public/images/icons' => 'img/icons',
      'public/stylesheets/ext-all.css' => 'css/ext-all.css',
      'public/stylesheets/xtheme-gray.css' => 'css/xtheme-gray.css',
      'public/stylesheets/styles.css' => '/css/styles.css',

      # erb: controllers/ext/index.html.erb, controllers/sessions/new.html.erb
      'app/views/sext/index.html.erb' => 'erb/index.html.erb',     
      'app/views/sessions/new.html.erb' => 'erb/new.html.erb'
    }
    
    TEMPLATE_ROOT = File.dirname(__FILE__) + "/../templates/"
    
    puts "Generating files..."
    files.each do |new_path, old_path|
      full_old_path = TEMPLATE_ROOT + old_path
      full_new_path = RAILS_ROOT + "/" + new_path
      FileUtils.mkdir_p(File.dirname(full_new_path))
      if(File.exists?(full_new_path))
      	puts "#{new_path} already exists."
      	puts "Do you want to replace it? (Y/N).  ('n' will print contents to STDOUT)"
      	input = ''
      	while((input != 'n')&&(input != 'N')&&(input != 'Y')&&(input != 'y'))
      		input << STDIN.gets.chomp
  		end
      	if(input == 'n')||(input=='N')
      		puts "File NOT Removed"
      		puts "Printing Contents of #{old_path}"
      		puts "\#====================================================="
      		puts "Location of example file: #{full_old_path}"
      		puts full_file
      		puts "\#====================================================="
		else
			puts "File Replaced with #{old_path}"
			FileUtils.rm_rf(full_new_path)
			FileUtils.cp_r(full_old_path, full_new_path)
		end
      else
      	puts "Generated #{full_new_path}"
      	FileUtils.cp_r(full_old_path, full_new_path)	
      end
      
    end
    
    puts "Removing index.html..."
    FileUtils.rm_rf("#{RAILS_ROOT}/public/index.html")
    puts "Adding users, sessions, and a root url to routes.rb"
    routes = IO.read(RAILS_ROOT + '/config/routes.rb')
  
    sext_routes = "|map|\n "
    sext_routes += "  map.resources :sessions\n\n "
    sext_routes += "  #this is the route to the html file\n"
    sext_routes += "  map.connect '/', :controller => 'sext', :action => 'index'\n\n"
    sext_routes += "  \#To use the users_controller instead of the sext_controller, do this:\n"
    sext_routes += "  \#map.resources 'users', :path_prefix => '/sext', :requirements => {:resource => 'users'},\n"
    sext_routes += "  \#                                                :collection => {:add => :post,\n"
    sext_routes += "  \#                                                                :remove => :post,\n"
    sext_routes += "  \#                                                                :csv_import => :post,\n"
    sext_routes += "  \#                                                                :csv_export => :get}\n\n"
    sext_routes += "  \#CSV Export/Import for Sext Resources\n"
    sext_routes += "  map.connect '/sext/:resource/csv_import', :controller => 'sext', :action => 'csv_import'\n"
    sext_routes += "  map.connect '/sext/:resource/csv_export', :controller => 'sext', :action => 'csv_export'\n\n"
    sext_routes += "  \#HABTM for sext Resources\n"
    sext_routes += "  map.connect '/sext/:resource/add', :controller => 'sext', :action => 'add'\n"
    sext_routes += "  map.connect '/sext/:resource/remove', :controller => 'sext', :action => 'remove'\n"
    sext_routes += "  \#Restful routes for all sext resources.\n"
    sext_routes += "  map.connect '/sext/:resource/', :controller => 'sext', :action => 'index', :conditions => {:method => :get}\n"
    sext_routes += "  map.connect '/sext/:resource/:id', :controller => 'sext', :action => 'show', :conditions => {:method => :get}\n"
    sext_routes += "  map.connect '/sext/:resource/', :controller => 'sext', :action => 'create', :conditions => {:method => :post}\n"
    sext_routes += "  map.connect '/sext/:resource/:id', :controller => 'sext', :action => 'update', :conditions => {:method => :put}\n"
    sext_routes += "  map.connect '/sext/:resource/:id', :controller => 'sext', :action => 'destroy', :conditions => {:method => :delete}\n\n"
    sext_routes += "  map.connect ':controller/:resource/:action/:id'\n"
  
    routes = routes.sub("|map|\n",  sext_routes)
    File.open(RAILS_ROOT + '/config/routes.rb', 'w') { |f| f.puts routes }
  end
end
