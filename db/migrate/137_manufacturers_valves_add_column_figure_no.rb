class ManufacturersValvesAddColumnFigureNo < ActiveRecord::Migration
  	def self.up
  		add_column :manufacturers_valves, :figure_no, :text
  	end

  	def self.down
  		remove_column :manufacturers_valves, :figure_no
  	end
end
