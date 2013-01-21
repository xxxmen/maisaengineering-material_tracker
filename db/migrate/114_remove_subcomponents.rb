class RemoveSubcomponents < ActiveRecord::Migration
  def self.up
    
    #delete the piping subcomponents from PIPE
    #rename "BRANCH CONN" to "BRANCH CONNECTIONS"
    pipe = PipingComponent.find_by_piping_component("PIPE")
    pipe.piping_subcomponents.each do |sc|
      sc.destroy
    end
    
    #clear out the branch connections subcomponents
    bc = PipingComponent.find_by_piping_component("BRANCH CONN")
    if(bc.nil?)
      bc = PipingComponent.find_by_piping_component("BRANCH CONNECTIONS")  
    end
    bc.piping_component = "BRANCH CONNECTIONS"
    bc.save!
    bc.piping_subcomponents.each do |sc|
      sc.destroy
    end
    bc.piping_subcomponents << PipingSubcomponent.create(:description => "SOCKOLET")
    bc.piping_subcomponents << PipingSubcomponent.create(:description => "WELDOLET")
    bc.piping_subcomponents << PipingSubcomponent.create(:description => "THREADOLET")
    bc.piping_subcomponents << PipingSubcomponent.create(:description => "ELBOWLET")
    bc.piping_subcomponents << PipingSubcomponent.create(:description => "LATROLET")
    
    @components = PipingComponent.find(:all, :include => :piping_subcomponents)
    
    icount = 0
    @components.each do |comp|
      if(comp.piping_subcomponents.size > 0)
        
          #puts "component: #{comp.piping_component}"
          
          new_components = []
          #create a new piping component for each piping subcomponent related to it
          comp.piping_subcomponents.each do |subcomp|
            #change this to create!
            ns = PipingComponent.create(:piping_component => subcomp.description.upcase)
            new_components << ns
            #puts "#{y ns}"
            icount += 1
            #if(icount % 1000 == 0)
            #    puts "#{icount} done"
            #  end
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
              #if(icount % 1000 == 0)
              #  puts "#{icount} done"
              #end
            end
          end
          
          #declare victory
      end #end if(comp.)
    end #end @components.each
    puts "#{icount} new pipingcomponents created"
    remove_column :material_requests, :subcomponent
    remove_column :requested_line_items, :subcomponent
    remove_column :bill_items, :piping_subcomp_id
    drop_table :piping_subcomponents
  end #end self.up

  def self.down
  end
end
