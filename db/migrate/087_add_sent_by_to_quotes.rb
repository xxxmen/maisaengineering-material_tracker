class AddSentByToQuotes < ActiveRecord::Migration
  def self.up
    add_column :quotes, :sent_by, :integer
    Quote.find(:all).each do |quote|
      material_request = quote.material_request
      if material_request && !material_request.purchaser_id.blank?
        quote.sent_by = material_request.purchaser_id
      elsif material_request && !material_request.planner_id.blank?
        quote.sent_by = material_request.planner_id
      elsif material_request && !material_request.requested_by_id.blank?
        quote.sent_by = material_request.requested_by_id
      end
      quote.save
    end
  end

  def self.down
    remove_column :quotes, :sent_by
  end
end
