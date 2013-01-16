#sizes to add:
#22"
#7 1/2"
#9"
#11"
#13 1/2"
#15"

#missing double quote in size_desc for Carson PCD id:273121

#erroneous issues:
#CARSON
#PIPING CLASS CAY: 
#PLUG VALVES
#They have 2" x 1" - 8" x 6"
#should this be two separate things?
#SAMPLING VALVE WITH BLEED RING
#Confirm that 1" x 3/4" ONLY is two valid sizes?
#Or is it 1 3/4" ONLY?

namespace :db do
  desc "Updates the piping sizes to numerically reflect the size_desc"  
  task :update_piping_sizes => :environment do
  	pcds = PipingClassDetail.find(:all)#, :limit => 100)
  	pcds.each_with_index do |detail,index|
  		if(detail.size_lower.nil? && detail.size_upper.nil?)
  			puts "detail #{index}/#{pcds.count}"
	  		PipingClassDetail.parse_sizes(detail)
  		end
  	end
  end
  
end
