class AddFugitiveEmissionsTestToManufacturersValves < ActiveRecord::Migration
  def self.up
  	add_column :manufacturers_valves, :passed_bp_fugitive_emissions_test, :boolean
  end

  def self.down
  	remove_column :manufacturers_valves, :passed_bp_fugitive_emissions_test
  end
end
