
		RecordChangelog.enable_recording = false

#Delete all pipingClassDetails with PipingComponents that have parent components
		pcd_to_destroy = PipingClassDetail.find(:all, :include => :piping_component, :conditions => 'piping_components.parent_id IS NOT NULL')
		puts "#{pcd_to_destroy.size} Details will be destroyed"
		pcd_to_destroy.each do |pcd_d|
			pcd_d.destroy
		end
		
		#Delete all PIping Components that have Parents
		components_to_destroy = PipingComponent.find(:all, :conditions => 'parent_id IS NOT NULL')
		puts "#{components_to_destroy.size} Piping Components will be destroyed"
		components_to_destroy.each do |comp_d|
			comp_d.destroy
		end
		
		#create all the new PipingComponents with Parent Components(from our list)
		#find our Branch Connections and Fittings Components
		#rename Branch Conn to branch connections
		bc = PipingComponent.find_by_piping_component("BRANCH CONN")
		
    if(bc.nil?)
      bc = PipingComponent.find_by_piping_component("BRANCH CONNECTIONS")  
    end
		bc = PipingComponent.find_by_piping_component('BRANCH CONNECTIONS')
		puts "#{@branch_connection_subcomponents.size} BRANCH CONNECTIONS Sub Components will be created"
		@branch_connection_subcomponents.each do |comp_name|
			PipingComponent.create(:piping_component => comp_name, :parent_id => bc.id)
		end
		
		fit = PipingComponent.find_by_piping_component('FITTINGS')
		puts "#{@fitting_subcomponents.size} FITTING Sub Components will be created"
		@fitting_subcomponents.each do |comp_name|
			PipingComponent.create(:piping_component => comp_name, :parent_id => fit.id)
		end
		
		#find through all piping class details that are BC/FITTINGS
		pcd_parents = PipingClassDetail.find(:all, :include => :piping_component, :conditions => "piping_components.piping_component = 'FITTINGS' OR piping_components.piping_component = 'BRANCH CONNECTIONS'")
		
		puts "#{pcd_parents.size} = TOTAL NUMBER OF FITTING/BC PipingClassDetails}"
		#Create a new PCD for each subcomponents in BC/FITTINGS
		pcd_parents.each do |parent_pcd|
			puts "#{parent_pcd.piping_class.class_code} #{parent_pcd.piping_component.piping_component} BEING CREATED"	
			parent_pcd.piping_component.subcomponents.each do |new_subcomponent|
				p = PipingClassDetail.new(:attributes => parent_pcd.attributes)	
				p.piping_component = new_subcomponent
				p.save!
			end
			 
		end
		puts "Done with Subcomponent Creation"
		
