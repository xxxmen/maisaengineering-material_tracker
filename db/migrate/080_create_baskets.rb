class CreateBaskets < ActiveRecord::Migration
  def self.up
    create_table "baskets" do |t|
      t.integer :employee_id
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps 
    end    
  end

  def self.down
    drop_table "baskets"
  end
end
