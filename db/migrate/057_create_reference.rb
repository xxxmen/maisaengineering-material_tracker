class CreateReference < ActiveRecord::Migration
  def self.up
    create_table :refs do |t|
      t.integer :parent_id
      t.string :content_type
      t.string :filename
      t.integer :size
      t.integer :folder_id
      t.text :search_terms

      t.timestamps 
    end
  end

  def self.down
    drop_table :refs
  end
end
