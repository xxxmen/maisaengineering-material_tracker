class CreatePipingSubcomponent < ActiveRecord::Migration
  def self.up
    create_table :piping_subcomponents do |t|
      t.integer  :piping_component_id
      t.text     :description
    end
  end

  def self.down
    drop_table :piping_subcomponents
  end
end
