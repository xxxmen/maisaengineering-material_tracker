class AddCrossReferenceToPipingClasses < ActiveRecord::Migration

  def self.up
    add_column :piping_classes, :cross_reference_class_id, :integer
  end

  def self.down
    remove_column :piping_classes, :cross_reference_class_id
  end
end
