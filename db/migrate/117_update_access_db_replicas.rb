#Uses migration 104's up and down methods.
load "#{Rails.root}/db/migrate/104_create_access_db_replicas.rb"

class UpdateAccessDbReplicas < CreateAccessDbReplicas 
    def self.convert_all
    
    self.convert_piping_classes
    self.convert_piping_notes
    self.convert_piping_components
    

    self.convert_general_notes
    self.convert_valve_components
    self.convert_valves
    #done to here
    
#    debugger
    
    self.convert_pcds
    self.modify_subcomponents
  end
  def self.modify_subcomponents
  
    #delete the piping subcomponents from PIPE

    #rename "BRANCH CONN" to "BRANCH CONNECTIONS"
    
    #clear out the branch connections subcomponents
    bc = PipingComponent.find_by_piping_component("BRANCH CONN")
    if(bc.nil?)
      bc = PipingComponent.find_by_piping_component("BRANCH CONNECTIONS")  
    end
    bc.piping_component = "BRANCH CONNECTIONS"
    bc.save!
    
    
    @components = PipingComponent.find(:all, :conditions => ["((piping_component = 'BRANCH CONNECTIONS') OR (piping_component = 'FITTINGS'))" ])

    icount = 0
    @components.each do |comp|
        subcomponents = []
        #puts "component: #{comp.piping_component}"
        if(comp.piping_component == 'FITTINGS')
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
        elsif(comp.piping_component == 'BRANCH CONNECTIONS')
          subcomponents = ["SOCKOLET",
              "WELDOLET",
              "THREADOLET",
              "ELBOWLET",
              "LATROLET"]
        end
        new_components = []
        #create a new piping component for each piping subcomponent related to it
        subcomponents.each do |subcomp|
          #change this to create!
          ns = PipingComponent.create(:piping_component => subcomp.upcase)
          new_components << ns
          puts "#{y ns}"
          icount += 1
          
        end
        
        pcds = PipingClassDetail.find_all_by_piping_component_id(comp.id)
        pcds.each do |detail|
          new_components.each do |new_sub|
            #duplicate the piping class detail for each new piping component
            p = PipingClassDetail.new(:attributes => detail.attributes)
            p.piping_component = new_sub
            p.save!
            detail.piping_notes.each do |note|
              p.piping_notes << note
            end
                
            icount += 1
          end
        end
        
        #declare victory
    end #end @components.each
    puts "#{icount} new PipingComponents created"    
  end
  
  
end
