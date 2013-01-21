class AddSizeFieldsToPcd < ActiveRecord::Migration
  def self.up
  	add_column :piping_class_details, :size_lower, :decimal, :precision => 6, :scale => 3
  	add_column :piping_class_details, :size_upper, :decimal, :precision => 6, :scale => 3
  end

  def self.down
  	remove_column  :piping_class_details, :size_lower
  	remove_column  :piping_class_details, :size_upper
  end
end
