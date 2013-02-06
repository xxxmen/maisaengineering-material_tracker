=begin
This file is intended to be run from the console, or another migration.
The order of operations here is
#1. Create the temporary tables
CreateAccessDbReplicas.up_tables

#2. import the data from CSV(WARNINGs will be given, confirm the # of records matches your database)
CreateAccessDbReplicas.import 

#3. Convert all the temporary data to actual POPV data
CreateAccessDbReplicas.convert_all 

#4. delete the temporary data
CreateAccessDbReplicas.down_tables 


=end


#The TemporaryXXXXXX classes are just so we can access via ActiveRecord.
#They are only for this migration and will not exist after it is done running.
class TemporaryArchiveLineClass < ActiveRecord::Base
    
end
class TemporaryClassValveNote < ActiveRecord::Base
    
end
class TemporaryGeneralNote < ActiveRecord::Base
    
end
class TemporaryLineClassNote < ActiveRecord::Base
    
end
class TemporaryManufacturer < ActiveRecord::Base
    
end
class TemporaryPipingClassComp < ActiveRecord::Base
    
end
class TemporaryPipingClassDtl < ActiveRecord::Base
    
end
class TemporaryPipingClassIndex < ActiveRecord::Base
    
end
class TemporaryRevisionHistory < ActiveRecord::Base
    
end
class TemporaryValveComponent < ActiveRecord::Base
    
end
class TemporaryValveDetail < ActiveRecord::Base
    
end
class TemporaryValveManufacturer < ActiveRecord::Base
    
end
class TemporaryValveNote < ActiveRecord::Base
    
end
#used for join table
class PipingNotesPipingClassDetail < ActiveRecord::Base
end
class CreateAccessDbReplicas < ActiveRecord::Migration
  def self.up
  	#1. Create the temporary tables
	self.up_tables
	
	#2. import the data from CSV(WARNINGs will be given, confirm the # of records matches your database)
	self.import 
	
	#3. Convert all the temporary data to actual POPV data
	self.convert_all 
	
	#4. delete the temporary data
	self.down_tables 

  end
  
  def self.down
  	#do nothing, as the self.up is atomic
  end	


  #this will create the tables exactly as they are defined in the POPV data
  def self.up_tables
    #"Class_Code","Service","Equ_Line_Class","Last_updt_id","Last_updt_date"
    create_table :temporary_archive_line_classes, {:id => false, :force => true} do |t|
        t.string :Class_Code
        t.string :Service
        t.string :Equ_Line_Class
        t.string :Last_updt_id
        t.datetime :Last_updt_date
    end
    
    
    #"Class_Code","Valve_No","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_class_valve_notes, {:id => false, :force => true} do |t|
        t.string :Class_Code
        t.string :Valve_No
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    
    
   #"Section_No","Section_Name","Section_Text","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_general_notes, {:id => false, :force => true} do |t|
        t.string :Section_No
        t.string :Section_Name
        t.text :Section_Text
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    
    #"Note_No","Note_Text","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_line_class_notes, {:id => false, :force => true} do |t|
        t.string :Note_No
        t.text :Note_Text
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    
    #"Manuf_Name","Contact_Name","Street","City","State","Zip","Phone_No","Alt_Phone_No","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_manufacturers, {:id => false, :force => true} do |t|
        t.string :Manuf_Name
        t.string :Contact_Name
        t.string :Street
        t.string :City
        t.string :State
        t.string :Zip
        t.string :Phone_No
        t.string :Alt_Phone_No
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    
    #"Piping_Comp_Name","Display_Seq_No","Last_Updt_Id","Last_Updt_date"
    create_table :temporary_piping_class_comps, {:id => false, :force => true} do |t|
        t.string :Piping_Comp_Name
        t.string :Display_Seq_No
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    
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
        t.datetime :Last_updt_date
    end
    
    #"Class_Code","Service","Consequence_Of_Failure","Flange_Rating","Max_Pressure","Max_Temp","Corrosion_Allow","Piping_Material","Small_Fitting","Valve_Body_Mtl","Valve_Trim","Gasket_Material","Gasket_Bolting","Instr_Spec","Comments","Last_Updt_Id","Last_Updt_date","Special_Note","Maintenance_Note"
    create_table :temporary_piping_class_indices, {:id => false, :force => true} do |t|
        t.string :Class_Code
        t.text :Service
        t.string :Consequence_Of_Failure
        t.string :Flange_Rating
        t.string :Max_Pressure
        t.string :Max_Temp
        t.string :Corrosion_Allow
        t.string :Piping_Material
        t.string :Small_Fitting
        t.string :Valve_Body_Mtl
        t.string :Valve_Trim
        t.string :Gasket_Material
        t.string :Gasket_Bolting
        t.string :Instr_Spec
        t.text :Comments
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
        t.text :Special_Note
        t.text :Maintenance_Note
    end
    
    #"Class_Code","Rev_Date","Piping_Comp_Name","Rev_Desc","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_revision_histories, {:id => false, :force => true} do |t|
        t.string :Class_Code
        t.string :Rev_Date
        t.string :Piping_Comp_Name
        t.text :Rev_Desc
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    
    #"Valve_Comp_Name","Display_Seq_No","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_valve_components, {:id => false, :force => true} do |t|
        t.string :Valve_Comp_Name
        t.string :Display_Seq_No
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    add_index :temporary_valve_components, :Valve_Comp_Name
    
    #"Valve_No","Valve_Comp_Name","Component_Text","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_valve_details, {:id => false, :force => true} do |t|
        t.string :Valve_No
        t.string :Valve_Comp_Name
        t.string :Component_Text
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    add_index :temporary_valve_details, :Valve_No
    
    #"Valve_No","Manuf_Name","Figure_No","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_valve_manufacturers, {:id => false, :force => true} do |t|
        t.string :Valve_No
        t.string :Manuf_Name
        t.string :Figure_No
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    
    #"Valve_No","Valve_Note","Valve_Manuf_Remarks","Last_Updt_Id","Last_Updt_Date"
    create_table :temporary_valve_notes, {:id => false, :force => true} do |t|
        t.string :Valve_No
        t.text :Valve_Note
        t.string :Valve_Manuf_Remarks
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
    end
    add_index :temporary_valve_notes, :Valve_No
    
  end

  #Delete all the tables
  def self.down_tables
    drop_table :temporary_archive_line_classes
    drop_table :temporary_class_valve_notes
    drop_table :temporary_general_notes
    drop_table :temporary_line_class_notes
    drop_table :temporary_manufacturers
    drop_table :temporary_piping_class_comps
    drop_table :temporary_piping_class_dtls
    drop_table :temporary_piping_class_indices
    drop_table :temporary_revision_histories
    drop_table :temporary_valve_components
    drop_table :temporary_valve_details
    drop_table :temporary_valve_manufacturers
    drop_table :temporary_valve_notes
  end
  
  
  #Import the CSV Data to the tables
  def self.import
  	if (RUBY_PLATFORM =~ /mswin32/) || (RUBY_PLATFORM =~ /i386-cygwin/)
    	fixtures_location = "r:/material_tracker/POPV_CONVERSION/"
	elsif (RUBY_PLATFORM =~ /i686-linux/ && Rails.env.development?)
	    fixtures_location = "/tmp/POPV_CONVERSION/"
	else
		fixtures_location = "#{Rails.root}/POPV_CONVERSION/"
	end
    table_infos = [
        {:table_name => 'temporary_archive_line_classes', :file_name =>'Archive_Line_Class.csv'},
        {:table_name => 'temporary_class_valve_notes',:file_name =>'Class_Valve_Note.csv'},
        {:table_name => 'temporary_general_notes',:file_name =>'General_Note.csv'},
        {:table_name => 'temporary_line_class_notes',:file_name =>'Line_Class_Note.csv'},
        {:table_name => 'temporary_manufacturers',:file_name =>'Manufacturer.csv'},
        {:table_name => 'temporary_piping_class_comps',:file_name =>'Piping_Class_Comp.csv'},
        {:table_name => 'temporary_piping_class_dtls',:file_name =>'Piping_Class_Dtl.csv'},
        {:table_name => 'temporary_piping_class_indices',:file_name =>'Piping_Class_Index.csv'},
        {:table_name => 'temporary_revision_histories',:file_name =>'Revision_History.csv'},
        {:table_name => 'temporary_valve_components',:file_name =>'Valve_Component.csv'},
        {:table_name => 'temporary_valve_details',:file_name =>'Valve_Detail.csv'},
        {:table_name => 'temporary_valve_manufacturers',:file_name =>'Valve_Manufacturer.csv'},
        {:table_name => 'temporary_valve_notes',:file_name =>'Valve_Note.csv'}
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
  
  
  def self.convert_piping_classes
    #Reload the PipingClass object
    Object.class_eval do
      remove_const PipingClass.to_s
    end
    load "#{Rails.root}/app/models/piping_class.rb"
    
    execute "delete from piping_classes"
    size = TemporaryPipingClassIndex.count

    puts "There are #{size} Temporary Piping Classes"
    
    all_indices = TemporaryPipingClassIndex.find(:all)
    !all_indices.each do |index|
        #puts "Class #{index.Class_Code} found"
        
        PipingClass.record_timestamps = false
        p = PipingClass.new(:archived => false,
                            :class_code => index.Class_Code.strip,
                            :comments => index.Comments.strip,
                            :corrosion_allow => index.Corrosion_Allow.strip,
                            :flange_rating => index.Flange_Rating.strip,
                            :gasket_bolting => index.Gasket_Bolting.strip,
                            :gasket_material => index.Gasket_Material.strip,
                            :instr_spec => index.Instr_Spec.strip,
                            :maintenance_note => index.Maintenance_Note.strip,
                            :max_pressure => index.Max_Pressure.strip,
                            :max_temp => index.Max_Temp.strip,
                            :piping_material => index.Piping_Material.strip,
                            :service => index.Service.strip,
                            :small_fitting => index.Small_Fitting.strip,
                            :special_note => index.Special_Note.strip,
                            :updated_at => index.Last_updt_date,
                            :valve_body_material => index.Valve_Body_Mtl.strip,
                            :valve_trim => index.Valve_Trim.strip)
        if(p.save == false)
            puts "ERROR SAVING PIPING CLASS #{p.class_code}"
        end
        PipingClass.record_timestamps = true
        
    end
    puts "Done converting Piping Classes, #{PipingClass.count} created."
    
  end
    
  def self.convert_piping_notes
    execute "delete from piping_notes"
    puts "There are #{TemporaryLineClassNote.count} Temporary Piping Notes"
    
    p = PipingNote.new(:note_number => "11",
                        :note_text => "REFERENCE YARWAY CATALOG FOR SIZING CHART.  FOR INSTALLATION DETAILS, REFER TO DWG. NOS. LA-0100-35 AND LA-0100-36 FOR CHERRY POINT AND P-0132-31305D-3 FOR LOS ANGELES.")
    if(p.save == false)
        puts "ERROR SAVING PIPING NOTE #{p.note_number}"
    end
    
    p = PipingNote.new(:note_number => "149",
                        :note_text => "--EMPTY--CHECK ME")
    if(p.save == false)
        puts "ERROR SAVING PIPING NOTE #{p.note_number}"
    end
        
    all_notes = TemporaryLineClassNote.find(:all)
    !all_notes.each do |note|
        PipingNote.record_timestamps = false
        p = PipingNote.new(:note_number => note.Note_No.strip,
                            :note_text => note.Note_Text.strip,
                            :updated_at => note.Last_updt_date)
        if(p.save == false)
            puts "ERROR SAVING PIPING NOTE #{p.note_number}"
        end
        PipingNote.record_timestamps = true
        
    end
    puts "Done converting Piping Notes, #{PipingNote.count} created."
    
  end
  def self.convert_piping_components
    execute "delete from piping_components"
    puts "There are #{TemporaryPipingClassComp.count} Temporary Piping Components"
    
    all_comps = TemporaryPipingClassComp.find(:all)
    !all_comps.each do |comp|
        PipingComponent.record_timestamps = false
        comp_name = comp.Piping_Comp_Name.strip
        comp_name = "PRESS CONN" if(comp_name == "PRESS  CONN")
        p = PipingComponent.new(:piping_component => comp_name,
                            :display_seq_no => comp.Display_Seq_No.strip,
                            :updated_at => comp.Last_updt_date)
        if(p.save == false)
            puts "ERROR SAVING PIPING COMPONENT #{p.note_number}"
        end
        PipingComponent.record_timestamps = true
    end
    puts "Done converting Piping Compnents, #{PipingComponent.count} created."
    
  end  	
  def self.convert_general_notes
    execute "delete from general_notes"
    puts "There are #{TemporaryGeneralNote.count} Temporary General Notes"
    
    all_notes = TemporaryGeneralNote.find(:all)
    !all_notes.each do |note|
        GeneralNote.record_timestamps = false
        p = GeneralNote.new(:section_name => note.Section_Name.strip,
                            :section_no => note.Section_No.strip,
                            :section_text => note.Section_Text.strip,
                            :updated_at => note.Last_updt_date)
        if(p.save == false)
            puts "ERROR SAVING GENERAL NOTE #{p.section_no}"
        end
        GeneralNote.record_timestamps = true
        
    end
    puts "Done converting General Notes, #{GeneralNote.count} created."
    
  end  	
  def self.convert_valve_components
    execute "delete from valve_components"
    puts "There are #{TemporaryValveComponent.count} Temporary Valve Components"
    
    all_components = TemporaryValveComponent.find(:all)
    ValveComponent.record_timestamps = false
    !all_components.each do |comp|
=begin        t.string :Valve_No
        t.string :Valve_Comp_Name
        t.string :Component_Text
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
=end  		
        
        p = ValveComponent.new(:component_name => comp.Valve_Comp_Name.strip,
                            :display_seq_no => comp.Display_Seq_No.strip,
                            :updated_at => comp.Last_updt_date)
        if(p.save == false)
            puts "ERROR SAVING VALVE COMPONENT #{p.component_name}"
        end
        
    end
    ValveComponent.record_timestamps = true
    puts "Done converting Valve Components, #{ValveComponent.count} created."
    
  end  	
  def self.convert_valves
  	#the valve components already exist.
  	
  	#we'll go through all the valve_details 
     execute "delete from valves"
     execute "delete from valves_valve_components"
     detail_count = TemporaryValveDetail.count
    puts "There are #{detail_count} Temporary Valve Detail"
    
    Valve.record_timestamps = false
    all_valve_details = TemporaryValveDetail.find(:all)
    
    !all_valve_details.each_with_index do |valve, index_no|
=begin        
		t.string :Valve_No
        t.string :Valve_Comp_Name
        t.string :Component_Text
        t.string :Last_Updt_Id
        t.datetime :Last_updt_date
=end  		
        valves = Valve.find_all_by_valve_code(valve.Valve_No.strip)
        
        this_valve = nil
        if(valves.size > 0)
        	this_valve = valves[0]
        else
        	temp_valve_note = TemporaryValveNote.find_by_Valve_No(valve.Valve_No.strip)
        	
        	manufacturers_remarks = temp_valve_note ? temp_valve_note.Valve_Manuf_Remarks.strip : ''
        	valve_note = temp_valve_note ? temp_valve_note.Valve_Note.strip : ''
        	
        	this_valve = Valve.new(:discontinued => false,
        							:valve_code => valve.Valve_No,
        							:manufacturers_remarks => manufacturers_remarks,
        							:valve_note => valve_note)
        							
        	if(this_valve.save == false)
	            puts "ERROR SAVING VALVE #{this_valve.valve_code}"
	        end
        end
        valve_components = ValveComponent.find_all_by_component_name(valve.Valve_Comp_Name.strip)
        if(valve_components.size <= 0)
        	puts "MAJOR ERROR, COULD NOT FIND VALVE COMPONENT #{valve.Valve_Comp_Name} FOR VALVE CODE #{valve.Valve_No}"
    	else
    		new_habtm_component = ValvesValveComponent.create(:valve_component_id => valve_components[0].id,
    														   :valve_id => this_valve.id,
    														   :component_text => valve.Component_Text.strip)
    		this_valve.valves_valve_components << new_habtm_component
        end
        
        if(index_no % 100 == 0)
        	puts "On Valve Detail #{index_no}/#{detail_count}"
        end
        
    end
    Valve.record_timestamps = true
    puts "Done converting Valves, #{Valve.count} created."
  end  	
  
  
  def self.convert_pcds
    #the valve components already exist.
  	
  	#we'll go through all the valve_details 
  	execute "delete from piping_class_details"
  	execute "delete from piping_notes_piping_class_details"
  	
    if(PipingNotesPipingClassDetail.column_names.include?('id'))
  	  remove_column :piping_notes_piping_class_details, :id
    end

    
  	detail_count = TemporaryPipingClassDtl.count
    puts "There are #{detail_count} Temporary Valve Detail"
    
    PipingClassDetail.record_timestamps = false
    all_details = TemporaryPipingClassDtl.find(:all, :order => "Class_Code ASC, Section_No ASC, Piping_Comp_Name ASC, Line_No ASC")
    
    
    unfound_component_count = 0
    unfound_components = []
    unfound_valve_count = 0
    unfound_valves = []
    previous_detail = nil
    current_description = ""
    state_alone_item = 0
    state_description_item = 1
    state_detail_item = 2
    !all_details.each_with_index do |current_detail, index_no|
    	
    	
=begin        
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
        t.datetime :Last_updt_date
=end  		
        piping_class = PipingClass.find_all_by_class_code(current_detail.Class_Code.strip)
        
        comp_name = current_detail.Piping_Comp_Name.strip
        comp_name = "PRESS CONN" if(comp_name == "PRESS  CONN")
        piping_component = PipingComponent.find_all_by_piping_component(comp_name)
        
        if(comp_name.include?("(FOR C.P. ONLY)") && piping_component.empty?)
        	last_comp = PipingComponent.find(:all, :order => "display_seq_no DESC")[0]
        	
        	piping_component = [PipingComponent.create(:display_seq_no => last_comp.display_seq_no + 1,
        						:piping_component => comp_name)]
        end
        
        
        valve = Valve.find_all_by_valve_code(current_detail.Valve_No.strip)
        
        #class and component are required.
        if(piping_class.size <= 0)
        	puts "Could not find Piping CLASS #{current_detail.Class_Code} for Detail with Piping Class: #{current_detail.Class_Code} Piping_Comp_Name:#{current_detail.Piping_Comp_Name} and Line_No #{current_detail.Line_No}"
        	next
        else
        	piping_class = piping_class[0]
        end
        if(piping_component.size <= 0)
        	unfound_component_count += 1
        	unfound_components << current_detail.Piping_Comp_Name
        	
        	puts "Could not find Piping COMPONENT #{current_detail.Piping_Comp_Name} for Detail with Piping Class: #{current_detail.Class_Code} Piping_Comp_Name:#{current_detail.Piping_Comp_Name} and Line_No #{current_detail.Line_No}"
        	next
        else
        	piping_component = piping_component[0]
        end
        
        #valve is not
        if(current_detail.Valve_No.strip != "") && (valve.size <= 0)
        	unfound_valve_count += 1
        	unfound_valves << current_detail.Valve_No
        	
        	puts "Could not find Piping Valve #{current_detail.Valve_No.strip} for Detail with Piping Class: #{current_detail.Class_Code} Piping_Comp_Name:#{current_detail.Piping_Comp_Name} and Line_No #{current_detail.Line_No}"
        	next
        else
        	valve = valve[0]
        end
        
        if(index_no + 1 >= all_details.size)
        	next_detail = nil	
        else
        	next_detail = all_details[index_no + 1]
        end
        
        current_state = -1
        #determine what state we're in
        if(current_detail.Size_Desc.blank?)
        	if(next_detail.nil?) 
        		#it can also be alone if there are NO more details, and the Size_Desc is blank.
        		current_state = state_alone_item
        	elsif(next_detail.Size_Desc.blank?) && 
        		 (next_detail.Line_No.to_i != (current_detail.Line_No.to_i + 1))
        		#it's alone if the size_desc is blank and the Line_No is NOT sequential
        		current_state = state_alone_item
        	else
        		#Else If it's not alone, AND the Size_Desc is blank, then it's a Description
        		current_state = state_description_item
        	end
        else
        	#Else it is a detail item.
        	current_state = state_detail_item
        end
        
        this_description = current_detail.Description
        
        if(current_state == state_description_item)
        	#Description Items aren't actually saved, 
        	#We just keep their description as the current description for the next detail items
        	current_description = this_description
        elsif(current_state == state_alone_item)
        	#Alone items get the size ALL
        	#Alone Items get no Detail_Description
			#puts "Creating #{current_detail.Class_Code.strip} Section #{current_detail.Section_No.strip}  Component #{current_detail.Piping_Comp_Name.strip} Size ALL - ALONE"
       		p = PipingClassDetail.create(:piping_class_id => piping_class.id,
       						:piping_component_id => piping_component.id,
       						:valve_id => (valve ? valve.id : nil),
       						:description => this_description,
       						:size_desc => "ALL",
       						:section_no => current_detail.Section_No)
       						
       		list = ['','1','2','3','4']
	       	list.each do |list_num|
	       		note = current_detail.send("Note_No#{list_num}").strip
	       		
				if(!note.blank?)
					pn = PipingNote.send("find_by_note_number", note)
					if(!pn.nil?)
						p.piping_notes << pn if(!p.piping_notes.include?(pn))
					else
						puts "Missing Piping Note #{note}"
					end
				end
			end
        else
        	#puts "Creating #{current_detail.Class_Code.strip} Section #{current_detail.Section_No.strip}  Component #{current_detail.Piping_Comp_Name.strip} Size #{current_detail.Size_Desc.strip}"
        	p = PipingClassDetail.create(:piping_class_id => piping_class.id,
       						:piping_component_id => piping_component.id,
       						:valve_id => (valve ? valve.id : nil),
       						:description => (current_description + " -- " + this_description),
       						:size_desc => current_detail.Size_Desc,
       						:section_no => current_detail.Section_No)
			list = ['','1','2','3','4']
	       	list.each do |list_num|
	       		note = current_detail.send("Note_No#{list_num}").strip
				if(!note.blank?)
					pn = PipingNote.send("find_by_note_number", note)
					
					if(!pn.nil?)
						p.piping_notes << pn if(!p.piping_notes.include?(pn))
					else
						puts "Missing Piping Note #{note}"
					end
				end
			end
        end
        
        
        
        
        if((index_no + 1) % 100 == 0)
        	puts "On Valve Detail #{index_no}/#{detail_count}"
        	#puts "Leaving loop"
        	#break
        end
    	previous_detail = current_detail    
    end
    
    PipingClassDetail.record_timestamps = true
    puts "Done converting Piping Class Details, #{PipingClassDetail.count} created."
    
    
    puts  "#{unfound_component_count} with components we couldn't find"
    puts "Size of the unfound component list is: #{unfound_components.uniq.size}"
    unfound_components.uniq.sort.each do |component_name|
    	puts "#{component_name}"
    end
    puts "Size of the unfound component list is: #{unfound_components.uniq.size}"
    
    puts  "#{unfound_valve_count} with valves we couldn't find"
    puts "Size of the unfound valve list is: #{unfound_valves.uniq.size}"
    unfound_valves.uniq.sort.each do |valve_name|
    	puts "#{valve_name.strip}"
    end
    puts "Size of the unfound valve list is: #{unfound_valves.uniq.size}"
    
    
    
    #CreateAccessDbReplicas.up
    #CreateAccessDbReplicas.import
    #CreateAccessDbReplicas.down
    #CreateAccessDbReplicas.reload
    #CreateAccessDbReplicas.convert_pcds
    #CreateAccessDbReplicas.convert_all
  end
  
  def self.update_piping_subcomponents
  	execute "delete from piping_subcomponents"
  	fitting = PipingComponent.find_by_piping_component("FITTINGS")
  	pipe = PipingComponent.find_by_piping_component("PIPE")
  	
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => 'coupling')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => 'tee')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => 'concentric reducer')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => 'eccentric reducer')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => 'reducing tee')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => '90 deg elbow')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => '45 deg elbow')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => 'elbowlet')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => 'latrolet')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => 'cross')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => 'cap')
PipingSubcomponent.create(:piping_component_id => fitting.id,:description => '90 deg reducing elbow')

PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'pipe nipple, PBE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'pipe nipple, TBE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'pipe nipple, PE x TE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, PBE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, TBE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, BBE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, PLE x PSE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, PLE x BSE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, PLE x TSE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, BLE x PSE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, BLE x BSE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, BLE x TSE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, TLE x PSE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, TLE x BSE')
PipingSubcomponent.create(:piping_component_id => pipe.id,:description => 'swage nipple, TLE x TSE')
  end
  
  
  def self.convert_all
    
    self.convert_piping_classes
    self.convert_piping_notes
    self.convert_piping_components
    self.update_piping_subcomponents
    self.convert_general_notes
    self.convert_valve_components
    self.convert_valves
    #done to here
    
    self.convert_pcds
    
  end
  
  
  
  def self.reload
    load "#{Rails.root}/lib/access_temp_migration.rb"
  end
  
  def self.execute_sql(command)
    execute command
  end
end
