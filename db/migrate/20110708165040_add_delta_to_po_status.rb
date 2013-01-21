class AddDeltaToPoStatus < ActiveRecord::Migration
  def self.up
  	
  	add_column :po_statuses, :delta, :boolean, :default => true, :null => false
  	
  end

  def self.down
  	remove_column :po_statuses, :delta  	
  end
end
