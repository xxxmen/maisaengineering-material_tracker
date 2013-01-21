class AddUpdatedAtToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :updated_at, :datetime
    Event.find(:all).each do |event|
      event.updated_at = event.created_at
      event.save
    end
  end

  def self.down
    remove_column :events, :updated_at
  end
end
