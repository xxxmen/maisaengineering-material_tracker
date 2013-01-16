namespace :db do
  desc "Cleans up the ordered line items to match material requests"
  
  task :cleanup_line_items => :environment do
    orders = RequestedLineItem.find(:all, :conditions => "requested_line_items.ordered_line_item_id IS NOT NULL AND (SELECT COUNT(*) FROM ordered_line_items WHERE ordered_line_items.po_id = purchase_orders.id) > 1", :include => {:ordered_line_item => :order}).map { |r| r.ordered_line_item.order }.uniq
    
    orders.each do |order|
      ordered_line_items = order.ordered_line_items
      ordered_line_items = ordered_line_items.sort do |first, second|
        a = first.requested_line_item.blank? ? 5000 : first.requested_line_item.id
        b = second.requested_line_item.blank? ? 5000 : second.requested_line_item.id
        a <=> b
      end
      
      ordered_line_items.each_with_index do |ordered_line_item, index|
        ordered_line_item.line_item_no = index + 1
        ordered_line_item.save
      end
    end
    
  end
  
end