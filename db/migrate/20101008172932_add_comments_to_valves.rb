class AddCommentsToValves < ActiveRecord::Migration
  def self.up
  	add_column :valves, :comments, :text
  end

  def self.down
  	remove_column :valves, :comments
  end
end
