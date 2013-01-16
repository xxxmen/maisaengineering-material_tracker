class AddDefaultsToPipingAndValves < ActiveRecord::Migration
  	def self.up
  		change_column_default :piping_classes, :archived, 0
  		change_column_default :valves, :archived, 0
  	end

  	def self.down
  	end
end
