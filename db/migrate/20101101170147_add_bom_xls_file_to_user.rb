class AddBomXlsFileToUser < ActiveRecord::Migration
  def self.up
    add_column :employees, :bom_xls_file, :string
    execute "update employees set bom_xls_file='form_58001'"
  end

  def self.down
    remove_column :employees, :bom_xls_file
  end
end
