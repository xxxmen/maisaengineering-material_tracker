namespace "po" do
  desc "This will Recreate the fittings for a piping class."
  task :fix_pcd_notes => :environment do
    
class TemporaryPipingClassDtl < ActiveRecord::Base
end
class CreateTempPCDReplica < ActiveRecord::Migration
  #Import the CSV Data to the tables
  def self.import_pcds
  	if (RUBY_PLATFORM =~ /mswin32/) || (RUBY_PLATFORM =~ /i386-cygwin/)
      	fixtures_location = "r:/material_tracker/POPV_CONVERSION/"
  	elsif (RUBY_PLATFORM =~ /i686-linux/ && Rails.env.development?)
  	    fixtures_location = "/tmp/POPV_CONVERSION/"
  	else
  		fixtures_location = "#{Rails.root}/POPV_CONVERSION/"
	  end
    table_infos = [
        
        {:table_name => 'temporary_piping_class_dtls',:file_name =>'Piping_Class_Dtl.csv'}
    ]
                
    table_infos.each do |info|
        execute "delete from #{info[:table_name]};"
        execute "load data infile '#{fixtures_location}#{info[:file_name]}' into table po_tracker.#{info[:table_name]} fields terminated by ',' enclosed by '\"' ignore 1 lines;"
        
        #confirm that the correct amount of data was loaded
        #first count the lines in the CSV(assume a header line)
        num_csv_lines = 0
        f = File.open("#{fixtures_location}#{info[:file_name]}")
        num_csv_lines = f.readlines.size
        f.close
        
        #then compare it to the number of records inserted into our table
        klass = Module.const_get(info[:table_name].singularize.camelcase)
        num_table_lines = klass.count
        
        if(num_csv_lines - 1 != num_table_lines)
            puts "WARNING, THERE WERE #{num_csv_lines} lines in #{info[:file_name]} and there are only #{num_table_lines} lines in the table"
        end
    end
    
    #Ended 
    puts "Ended with:"
    table_infos.each do |info|
		klass = Module.const_get(info[:table_name].singularize.camelcase)
        num_table_lines = klass.count
    	puts "#{num_table_lines} #{info[:table_name].singularize.camelcase}"
    end
  end
    
  def self.create_temp_piping_class_details
    #"Class_Code","Section_No","Piping_Comp_Name","Line_No","Size_Desc","Description","Valve_No","Note_No","Note_No1","Note_No2","Note_No3","Note_No4","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_piping_class_dtls, {:id => false, :force => true} do |t|
        t.string :Class_Code
        t.string :Section_No
        t.string :Piping_Comp_Name
        t.string :Line_No
        t.string :Size_Desc
        t.string :Description
        t.string :Valve_No
        t.string :Note_No
        t.string :Note_No1
        t.string :Note_No2
        t.string :Note_No3
        t.string :Note_No4
        t.string :Last_Updt_Id
        t.datetime :Last_Updt_date
    end
    
  end
  
end
  

    CreateTempPCDReplica.create_temp_piping_class_details
    CreateTempPCDReplica.import_pcds
    
    #Find all temp pcds who 
    missing_pcds = TemporaryPipingClassDtl.find_by_sql("SELECT *
FROM temporary_piping_class_dtls
WHERE (((Size_Desc)='' Or (Size_Desc) Is Null) AND ((Note_No)<>'' And (Note_No) Is Not Null));")
    missing_pcds.each do |missing_piping|
      
      
      
      missing_piping.Piping_Comp_Name = "PRESS CONN" if(missing_piping.Piping_Comp_Name.strip == "PRESS  CONN")
      missing_piping.Piping_Comp_Name = "BRANCH CONNECTIONS" if(missing_piping.Piping_Comp_Name.strip == "BRANCH CONN" )
      
      #For each missing note detail.
      #Figure out the piping class
      piping_class = PipingClass.find_by_class_code(missing_piping.Class_Code.strip)
      
      #figure out the piping_component
      piping_component = PipingComponent.find_by_piping_component(missing_piping.Piping_Comp_Name.strip)
      if(piping_component.blank?) 
        if(missing_piping.Piping_Comp_Name.strip.include?("(FOR C.P. ONLY)"))
          puts "SKIPPING FOR C.P. ONLY NOT Found: #{missing_piping.Piping_Comp_Name.strip} "
          next
        end
        puts "CAN NOT FIND PIPING COMPONENT:  '#{missing_piping.Piping_Comp_Name.strip}'"
        return
      end
      if(piping_class.blank?)
        puts "CAN NOT FIND PIPING CLASS: '#{missing_piping.Class_Code.strip}'"
        return
      end
      
      puts ""
      puts "PIPING CLASS: #{missing_piping.Class_Code.strip} PIPING COMPONENT #{missing_piping.Piping_Comp_Name.strip}"      
      missing_notes = []
      list = ['','1','2','3','4']
      list.each do |list_num|
        note = missing_piping.send("Note_No#{list_num}").strip
        if(!note.blank?)
          pn = PipingNote.send("find_by_note_number", note)
          if(!pn.nil?)
            puts "FOUND MISSING Piping Note #{pn.note_number}"
            #p.piping_notes << pn if(!p.piping_notes.include?(pn))
            missing_notes << pn
          else
            puts "Missing Piping Note #{note}"
          end
        end
      end
      
      
      #Find the set of Piping Class Details that match it(since it's a header row,).  They can have any size, ALL, or anything.
      #in order to match, they must have the same description somewhere in their description.
      
      
      
      
      
      new_details = piping_class.piping_class_details.find(:all, :conditions => 
            ['description LIKE ? AND piping_component_id = ?', "#{missing_piping.Description.strip}%", piping_component.id])
      #IF WE HAVE A FITTINGS OR BRANCH CONN WE NEED TO TAKE THEIR SUB CLASSES INTO ACCOUNT!!!
      #Just add their details to the ones from the base class.
      subcomponents = []
      if(missing_piping.Piping_Comp_Name.strip == 'FITTINGS')
         subcomponents = [
              '45 DEG ELBOW',
              '90 DEG ELBOW',
              '90 DEG REDUCING ELBOW ',
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
      end
      if(missing_piping.Piping_Comp_Name.strip == 'BRANCH CONNECTIONS')
          subcomponents = ["SOCKOLET",
              "WELDOLET",
              "THREADOLET",
              "ELBOWLET",
              "LATROLET"]
       end
      subcomponents.each do |subcomp|
        #add all the subcomponents to the new_details list
        subcomponent = PipingComponent.find_by_piping_component(subcomp)
        if(subcomponent.blank?) 
          puts "CAN NOT FIND PIPING SUB COMPONENT:  '#{subcomp}'"
          return
        end
        subcomp_details = piping_class.piping_class_details.find(:all, :conditions => 
              ['description LIKE ? AND piping_component_id = ?', "#{missing_piping.Description.strip}%", subcomponent.id])
        subcomp_details.each do |this_subcomponent_detail|
          new_details << this_subcomponent_detail
        end
      end

      #Find all notes from the missing piping class detail 
      new_details.each do |p|
        #add all those notes to each item in the matching pcds list
          missing_notes.each do |this_n|
            puts "Adding Piping Note #{this_n.note_number} to CLASS/COMPONENT #{p.piping_class.class_code}/#{p.piping_component.piping_component} PCD_ID #{p.id}"
            p.piping_notes << this_n if(!p.piping_notes.include?(this_n))
          end
      end
    
    end
  end
end
