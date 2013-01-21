class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table :employees, :primary_key => "id" do |t|
      t.column :badge_no,                  :int
      t.column :last_name,                 :string
      t.column :first_name,                :string
      t.column :mi,                        :string
      t.column :login,                     :string
      t.column :company_id,                :int
      t.column :email,                     :string
      t.column :telephone,                 :string
      t.column :lock_version,              :int, :default => 0
      t.column :updated_at,                :datetime
      t.column :role,                      :int, :default => 1
      
      t.column :password,                  :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :dirty, :int

#      Removed
#      t.column :company,                   :string

    end    
  end

  def self.down
    drop_table :employees
  end
end
