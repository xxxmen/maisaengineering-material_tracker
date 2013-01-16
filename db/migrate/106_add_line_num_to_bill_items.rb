class AddLineNumToBillItems < ActiveRecord::Migration
  def self.up
  	add_column :bill_items, :line_num, :integer
  	
  	Bill.find(:all).each do |bill|
  		start_num = 1
  		bill.bill_items.each do |bill_item|
  			bill_item.line_num = start_num
  			bill_item.save
  			start_num += 1
  		end
  	end
  	
  end

  def self.down
  	remove_column :bill_items, :line_num
  end
end
