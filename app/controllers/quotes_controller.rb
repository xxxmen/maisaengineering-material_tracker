class QuotesController < ApplicationController
  before_filter :resource_enabled?
  before_filter :check_query, :only => [ :search ]
  
  
  def index
    Quote.filter(params, current_employee) do
      if(params[:o].blank?)
        params[:o] = "quotes.updated_at"
        params[:s]= "desc"
      end
      @quotes = Quote.list(params, :include => [:vendor, :material_request])
    end
  end
  
  def search
    Quote.filter(params, current_employee) do
      if(params[:o].blank?)
        params[:o] = "quotes.updated_at"
        params[:s]= "desc"
      end
      @quotes = Quote.full_text_search(params, {})
      return_search(@quotes)
    end
  end

  def new
    @quote = Quote.new
    render :action => :edit
  end

  def create
    @quote = Quote.new(params[:quote])
    save_and_show!
  end

  def update
    save_and_show!
  end
  
  private
  def save_and_show!
    @quote.update_attributes!(params[:quote])
    flash[:notice] = msg_for("Quote", @quote.description, @quote)
    redirect_to inventory_items_path
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "Inventory Item could not be saved properly due to error(s)"
    render :action => "edit"
  end
  
end
