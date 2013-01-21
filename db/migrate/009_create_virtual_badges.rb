class CreateVirtualBadges < ActiveRecord::Migration
  def self.up
    create_table :virtual_badges, :primary_key => "id" do |t|
      t.column :virtual_badge_no,             :int
      t.column :physical_badge_facility_code, :int
      t.column :physical_badge_id,            :int
      t.column :lock_version,                 :int, :default => 0
      t.column :updated_at,                   :datetime
      t.column :dirty, :int
    end    
  end

  def self.down
    drop_table :virtual_badges
  end
end
