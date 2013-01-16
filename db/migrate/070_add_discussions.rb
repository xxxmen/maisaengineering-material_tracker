class AddDiscussions < ActiveRecord::Migration
  def self.up
    add_column :quotes, :discussion, :text
    add_column :quotes, :discussion_updated_at, :datetime
    add_column :quotes, :discussion_flag, :boolean
  end

  def self.down
    remove_column :quotes, :discussion
    remove_column :quotes, :discussion_updated_at
    remove_column :quotes, :discussion_flag
  end
end
