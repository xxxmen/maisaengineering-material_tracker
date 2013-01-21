class MoveManufacturersBack < ActiveRecord::Migration
  def self.up
  	#create a backup table in the 'old_manufacturers_valves' join
#  	execute 'INSERT INTO manufacturers_valves (SELECT * FROM old_manufacturers_valves)'

    #clear out our old join table.
#    execute 'DELETE FROM old_manufacturers_valves'
  end

  def self.down
  end
end
