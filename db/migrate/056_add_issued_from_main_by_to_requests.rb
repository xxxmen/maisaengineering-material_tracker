class AddIssuedFromMainByToRequests < ActiveRecord::Migration
  def self.up
    add_column :material_requests, :issued_from_main_by, :integer
  end

  def self.down
    remove_column :material_requests, :issued_from_main_by
  end
end
