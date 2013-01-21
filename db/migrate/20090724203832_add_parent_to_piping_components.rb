class AddParentToPipingComponents < ActiveRecord::Migration
  def self.up
  	add_column :piping_components, :parent_id, :integer
  end

  def self.down
  	remove_column :piping_components, :parent_id
  end
end
