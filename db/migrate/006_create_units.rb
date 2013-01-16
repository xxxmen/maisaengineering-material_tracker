class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table "units", :primary_key => "id" do |t|
      t.column "description", :string, :limit => 80
      t.column :lock_version, :int, :default => 0
      t.column "updated_at", :datetime
      t.column "created_at", :datetime
      t.column :dirty, :int
    end
  end

  def self.down
    drop_table :units
  end
end
