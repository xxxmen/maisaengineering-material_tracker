class AddAcknowledgedByToQuotes < ActiveRecord::Migration
  def self.up
    add_column :quotes, :acknowledged_by, :integer
    Quote.find(:all, :include => :material_request).each do |quote|
      next unless quote.material_request
      quote.acknowledged_by = quote.material_request.requested_by_id
      quote.save
    end
  end

  def self.down
    remove_column :quotes, :acknowledged_by
  end
end
