require 'sha1'

class AddAccessKeyToVendor < ActiveRecord::Migration
  def self.up
    add_column :vendors, :access_key, :string
    Vendor.find(:all).each do |v|
      v.access_key = SHA1.hexdigest('--' + v.id.to_s + '--' + Time.now.to_s + '--')
      v.save!
    end
  end

  def self.down
    remove_column :vendors, :access_key
  end
end
