class GeneralNotesChangeSectionText < ActiveRecord::Migration
  	def self.up
  		change_column :general_notes, :section_text, :text
  	end

  	def self.down
  	end
end
