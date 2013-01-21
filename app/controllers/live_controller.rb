class LiveController < ApplicationController
  def index
    @material_requests = MaterialRequest.find(:all, :conditions =>
            ["acknowledged_by IS NULL AND drafted_by IS NULL"], :order => "id DESC")
    @material_request_ids = @material_requests.map(&:id)
    
    @quotes = Quote.find(:all, :conditions => "acknowledged_by IS NULL AND
            (SELECT COUNT(*) FROM quote_items WHERE quote_items.quote_id = quotes.id AND quote_items.price > 0.0) > 0", 
            :order => "quotes.id DESC")
    @quote_ids = @quotes.map(&:id)
  end
  
  def update_page
    # params[:material_request_ids] = "1,2,3,4,5"
    @material_request_ids = params[:material_request_ids].split(",").map { |num| num.to_i }
    @material_requests = MaterialRequest.find(:all, :conditions =>
            ["acknowledged_by IS NULL AND drafted_by IS NULL AND
              id NOT IN (?)", @material_request_ids], :order => "id DESC")
    @remove_existing_requests = MaterialRequest.find(:all, :conditions =>
            ["(acknowledged_by IS NOT NULL OR drafted_by IS NOT NULL) AND
              id IN (?)", @material_request_ids], :order => "id")

    @quote_ids = params[:quote_ids].split(",").map { |num| num.to_i }
    @quotes = Quote.find(:all, :conditions => ["acknowledged_by IS NULL AND
                          (SELECT COUNT(*) FROM quote_items WHERE quote_items.quote_id = quotes.id AND quote_items.price > 0.0) > 0
                          AND id NOT IN (?)", @quote_ids], 
                          :order => "quotes.id DESC")
    @remove_existing_quotes = Quote.find(:all, :conditions => ["(acknowledged_by IS NOT NULL OR
              (SELECT COUNT(*) FROM quote_items WHERE quote_items.quote_id = quotes.id AND quote_items.price > 0.0) <= 0)  
              AND id IN (?)", @quote_ids], :order => "id")
    
    render :update do |page|      
      (@material_requests + @quotes).each { |record| add_to(page, record) }
      (@remove_existing_requests + @remove_existing_quotes).each { |record| remove_from(page, record) }
    end # end render :update
  end    
end
