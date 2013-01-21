class RemoveEmissions < ActiveRecord::Migration
  def self.up
    remove_column :manufacturers_valves, :passed_bp_fugitive_emissions_test
    #remove_column :old_manufacturers_valves, :passed_bp_fugitive_emissions_test
  end

  def self.down
    add_column :manufacturers_valves, :passed_bp_fugitive_emissions_test, :boolean
  end
end
