class ChangePipingClassNoteToPipingNoteId < ActiveRecord::Migration
  def self.up
    rename_column :piping_notes_piping_class_details, :piping_class_note_id, :piping_note_id
  end

  def self.down
    rename_column :piping_notes_piping_class_details, :piping_note_id, :piping_class_note_id
  end
end
