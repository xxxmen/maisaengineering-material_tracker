class ChangeOrderedLineItemsAndRequestedLineItems < ActiveRecord::Migration
  def self.up
     add_column :ordered_line_items, :requested_line_item_id, :integer
     
     #SQL to change the ids....
     @requested_line_items = RequestedLineItem.find(:all, :conditions => ["ordered_line_item_id IS NOT NULL"])
     @requested_line_items.each do |requested_line_item|
      #RequestedLineItem.disable_ferret(:always)
      OrderedLineItem.disable_ferret
     	ordered_line_item = OrderedLineItem.find(requested_line_item.ordered_line_item_id)	
     	if(ordered_line_item)
     		ordered_line_item.requested_line_item_id = requested_line_item.id
     		ordered_line_item.save!
     	else
     		puts "ERROR, ORDERED LINE ITEM: #{requested_line_item.ordered_line_item_id} DOES NOT EXIST"	
 		end
 	 end
     add_index :ordered_line_items, :requested_line_item_id
     remove_column :requested_line_items, :ordered_line_item_id
  end

  def self.down
	add_column :requested_line_items, :ordered_line_item_id, :integer
	
    #SQL to change the ids BACK
     @ordered_line_items = OrderedLineItem.find(:all, :conditions => ["requested_line_item_id IS NOT NULL"])
     @ordered_line_items.each do |ordered_line_item|
     	requested_line_item = RequestedLineItem.find(ordered_line_item.requested_line_item_id)	
     	if(requested_line_item)
     		requested_line_item.ordered_line_item_id = ordered_line_item.id
     		requested_line_item.save!
     	else
     		puts "ERROR, REQUESTED LINE ITEM: #{ordered_line_item.requested_line_item_id} DOES NOT EXIST"	
 		end
 	 end
 	 add_index :requested_line_items, :ordered_line_item_id
     remove_column :ordered_line_items, :requested_line_item_id
  end
end
