class CreateCompanies < ActiveRecord::Migration
  def self.up
    # FIXME: change to 'companies'
    create_table :companies, :primary_key => :id do |t|
      t.column :name, :string
      t.column :address, :text
      t.column :city, :string
      t.column :state, :string
      t.column :zip, :string
      t.column :telephone, :string
      t.column :fax, :string
      t.column :notes, :text
      t.column :lock_version, :int, :default => 0
      t.column :updated_at, :datetime
      t.column :dirty, :int
    end
  end

  def self.down
    drop_table :companies
  end
end
