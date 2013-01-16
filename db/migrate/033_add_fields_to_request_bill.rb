class AddFieldsToRequestBill < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :size, :string
    add_column :material_requests, :klass, :string
    add_column :material_requests, :component, :string
    add_column :material_requests, :subcomponent, :string
  end

  def self.down
    remove_column :material_requests, :size
    remove_column :material_requests, :klass
    remove_column :material_Requests, :component
    remove_column :material_requests, :subcomponent
  end
end
