class AddOrderToPipingClassDetail < ActiveRecord::Migration
  def self.up
    add_column :piping_class_details, :order, :integer, :default => 0

    #this is a fix to update the bad data in class GFA
    execute "update piping_class_details SET size_desc='ALL' where size_desc =''"
    RecordChangelog.enable_recording = false
    PipingClass.find(:all, :order => "class_code ASC").each do |piping_class|
      piping_class.reset_details_order
    end
    @@enable_recording = true

  end

  def self.down
    remove_column :piping_class_details, :order
  end
end
