class AddIndexToPipingNotesPipingClassDetails < ActiveRecord::Migration
  def self.up
    add_index :piping_notes_piping_class_details, [:piping_class_detail_id, :piping_note_id], :name => 'pn_pcd_index'
  end

  def self.down
  	remove_index :piping_notes_piping_class_details, :name => 'pn_pcd_index'
  end
end
