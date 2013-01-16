class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :first_name
      t.string   :last_name
      t.string   :mi
      t.string   :login
      t.string   :crypted_password
      t.string   :salt
      t.string   :email
      t.string   :telephone
      t.string   :fax
      t.string   :cell
      t.string   :remember_token
      t.datetime :remember_token_expires_at

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
