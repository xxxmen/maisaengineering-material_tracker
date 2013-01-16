
class UpdatePcdSizes < ActiveRecord::Migration
  def self.up
  	#sizes to add:
#22"
#7 1/2"
#9"
#11"
#13 1/2"
#15"
	PipingSize.create(:piping_size => "1 1/2\"", :numerical_size => 1.5)
  	PipingSize.create(:piping_size => "22\"", :numerical_size => 22)
  	PipingSize.create(:piping_size => "7 1/2\"", :numerical_size => 7.5)
  	PipingSize.create(:piping_size => "9\"", :numerical_size => 9)
  	PipingSize.create(:piping_size => "11\"", :numerical_size => 11)
  	PipingSize.create(:piping_size => "13 1/2\"", :numerical_size => 13.5)
  	PipingSize.create(:piping_size => "15\"", :numerical_size => 15)

  end

  def self.down
  end
end
