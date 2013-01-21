class CreatePipingMaterials < ActiveRecord::Migration
  def self.up
    create_table :piping_classes do |t|
      t.column :piping_class, :string
    end
    
    create_table :piping_codes do |t|
      t.column :piping_code, :string
    end
    
    create_table :piping_components do |t|
      t.column :piping_component, :string
    end
    
    create_table :piping_material_specifications do |t|
      t.column :piping_material_specification, :string
    end
    
    create_table :piping_materials do |t|
      t.column :piping_material, :string
    end
    
    create_table :piping_sizes do |t|
      t.column :piping_size, :string
    end
    
    create_table :unit_of_measures do |t|
      t.column :unit_of_measure, :string
    end
  end

  def self.down
    drop_table :piping_classes
    drop_table :piping_codes
    drop_table :piping_components
    drop_table :piping_material_specification
    drop_table :piping_materials
    drop_table :piping_sizes
    drop_table :unit_of_measures
  end
end
