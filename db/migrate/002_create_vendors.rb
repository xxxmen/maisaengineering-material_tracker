class CreateVendors < ActiveRecord::Migration
  def self.up
    create_table :vendors, :primary_key => "id" do |t|
      t.column :vendor_no, :string
      t.column :name, :string
      t.column :email, :string
      t.column :account_no, :string
      t.column :address, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zip, :string
      t.column :country, :string
      t.column :telephone, :string
      t.column :fax, :string
      t.column :contact_name, :string
      t.column :contact_telephone, :string
      t.column :notes, :text
      t.column :lock_version, :int, :default => 0
      t.column :updated_at, :datetime
      t.column :dirty, :int
    end    
  end

  def self.down
    drop_table :vendors
  end
end
