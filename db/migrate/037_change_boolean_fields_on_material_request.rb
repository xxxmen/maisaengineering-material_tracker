class ChangeBooleanFieldsOnMaterialRequest < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :authorized_by, :integer
    add_column :material_requests, :acknowledged_by, :integer
    add_column :material_requests, :stage_at, :datetime
    
    remove_column :material_requests, :authorized
    remove_column :material_requests, :acknowledged
    remove_column :material_requests, :stage
  end

  def self.down
    remove_column :material_requests, :authorized_by
    remove_column :material_requests, :acknowledged_by
    remove_column :material_requests, :stage_at

    add_column :material_requests, :authorized, :boolean
    add_column :material_requests, :acknowledged, :boolean
    add_column :material_requests, :stage, :boolean    
  end
end
