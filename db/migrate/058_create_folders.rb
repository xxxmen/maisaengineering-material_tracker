class CreateFolders < ActiveRecord::Migration
  def self.up
    create_table :folders do |t|
      t.string :name

      t.timestamps 
    end
    
    Folder.create!(:name => "Inbox")
  end

  def self.down
    drop_table :folders
  end
end
