class AddDeltaToQuotes < ActiveRecord::Migration
  def self.up  	
  	add_column :quotes, :delta, :boolean, :default => true, :null => false  	
  end

  def self.down
  	remove_column :quotes, :delta  	
  end
end
