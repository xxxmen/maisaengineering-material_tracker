# == Schema Information
# Schema version: 121
#
# Table name: piping_notes
#
#  id          :integer(11)   not null, primary key
#  created_at  :datetime
#  note_text   :string(255)
#  updated_at  :datetime
#  note_number :integer(11)
#

class PipingNote < ActiveRecord::Base
    generator_for :note_text, :start => 'Note A' do |prev|
        prev.succ
    end

    generator_for :note_number, :start => 1 do |prev|
        prev.succ
    end
end

