class AddFaxToEmployee < ActiveRecord::Migration
  def self.up
     add_column :employees, :fax, :string
  end

  def self.down
    remove_column :employees, :fax
  end
end
