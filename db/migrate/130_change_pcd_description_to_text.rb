class ChangePcdDescriptionToText < ActiveRecord::Migration
  def self.up
    change_column :piping_class_details, :description, :text
  end

  def self.down
    change_column :piping_class_details, :description, :string
  end
end
