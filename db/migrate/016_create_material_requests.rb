class CreateMaterialRequests < ActiveRecord::Migration
  def self.up
    create_table :material_requests, :force => true do |t|
      t.column :tracking, :int
      t.column :unit_id, :int
      t.column :planner_id, :int
      t.column :year, :string
      t.column :requested_by_id, :int
      t.column :date_requested, :date
      t.column :telephone, :string
      t.column :date_need_by, :date
      t.column :work_orders, :string
      t.column :deliver_to, :string
      t.column :ptm_no, :string
      t.column :stage, :boolean
      t.column :suggested_vendor, :string
      t.column :acknowledged, :boolean
      t.column :authorized, :int
    end
  end

  def self.down
    drop_table :material_requests
  end
end
