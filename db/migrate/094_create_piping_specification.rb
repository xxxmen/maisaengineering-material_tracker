class PipingSpecification < ActiveRecord::Base
  
end
class PipingDescription < ActiveRecord::Base
  
end
class CreatePipingSpecification < ActiveRecord::Migration
	
  def self.up
#    create_table "piping_specifications" do |t|
#      t.string :description
#      t.timestamps 
#    end
#    
#	create_table "piping_descriptions" do |t|
#		t.string :description
#		t.timestamps
#    end
#    add_index :piping_specifications, :description
#    add_index :piping_descriptions, :description
#    add_column :piping_class_details, :piping_specification_id, :integer
#    add_column :piping_class_details, :piping_description_id, :integer
#    add_index :piping_class_details, :description
#    #create all the piping specifications from the description in the PipingClassDetails.
#	#these will be different eventually....
#    piping_class_details = PipingClassDetail.find(:all).each do |detail|
#    	#we could have parsed the description for 'class' here.
#    	parsed_description = detail.description
#    	spec = PipingSpecification.find_by_description(parsed_description)
#    	if(spec != nil)
#    		detail.piping_specification_id = spec.id
#    		detail.save!
#    		puts "detail updated with spec id"
#		else
#			spec = PipingSpecification.new(:description => parsed_description)
#			spec.save!
#			detail.piping_specification = spec
#			detail.save!
#			puts "New PipingSpecification created"
#    	end
#    	
#    	desc = PipingDescription.find_by_description(parsed_description)
#    	if(desc != nil)
#    		detail.piping_description_id = desc.id
#    		detail.save!
#    		puts "detail updated with desc id"
#		else
#			desc = PipingDescription.new(:description => parsed_description)
#			desc.save!
#			detail.piping_description = desc
#			detail.save!
#			puts "New PipingDescription created"
#    	end
#    end
#    remove_index :piping_class_details, :description
#    remove_column :piping_class_details, :description
  end

  def self.down
#    add_column :piping_class_details, :description, :string
#    descriptions = PipingDescription.find(:all)
#    descriptions.each do |desc|	
#    	desc.piping_class_details.each do |detail|
#	    	detail.description = desc.description
#	    	detail.save!
#		end
#	end
#    
#    remove_column :piping_class_details, :piping_specification_id
#    remove_column :piping_class_details, :piping_description_id
#    drop_table "piping_specifications"
#    drop_table "piping_descriptions"
  end
end
