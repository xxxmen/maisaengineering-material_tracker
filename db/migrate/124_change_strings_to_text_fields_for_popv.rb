# Changes all the string columns listed below to text columns to fit more data.
class ChangeStringsToTextFieldsForPopv < ActiveRecord::Migration
    def self.up
        change_column :valves, :valve_note, :text
        change_column :user_notes, :note, :text
        change_column :piping_notes, :note_text, :text
        change_column :piping_classes, :service, :text        
    end

    def self.down
    
    end
end
