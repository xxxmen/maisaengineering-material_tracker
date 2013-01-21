namespace "po" do
  desc "This will Recreate the fittings for a piping class."
  task :refit => :environment do
    #specify the FIT_NAME=CA on the command line
    @class_name = ENV['FIT_NAME']
    if(@class_name.blank?)
      puts "MUST SPECIFY 'FIT_NAME=CLASS_NAME' on the command line"
      puts "DO NOT USE THIS UNLESS YOU KNOW EXPLICITLY WHAT IT DOES"
      return false      
    end
    
    @class = PipingClass.find_by_class_code(@class_name)
    
    @components = PipingComponent.find(:all, :conditions => ["(piping_component = 'FITTINGS')" ])
    comp = @components[0]
    
    
    
    new_component_names = ['45 DEG ELBOW',
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
    new_components = []
    new_component_names.map {|p| new_components << PipingComponent.find_by_piping_component(p)}
    
    new_components.each do |component_to_remove|
      puts "component_to_remove from PCD: #{component_to_remove.piping_component}"
      pcds = @class.piping_class_details.find_all_by_piping_component_id(component_to_remove.id)
      pcds.each do |det_to_del|
        puts "DELETING PCD: #{det_to_del.description}"
        PipingClassDetail.destroy(det_to_del.id)
      end
      
    end
    
    
    pcds = @class.piping_class_details.find_all_by_piping_component_id(comp.id)
    pcds.each do |detail|
      new_components.each do |new_sub|
        #duplicate the piping class detail for each new piping component
        p = PipingClassDetail.new(:attributes => detail.attributes)
        puts "CREATING PCD: #{new_sub.piping_component} #{p.description[0..30]}"
        p.piping_component = new_sub
        p.save!
        detail.piping_notes.each do |note|
          p.piping_notes << note
        end
      end
    end

  end
end
