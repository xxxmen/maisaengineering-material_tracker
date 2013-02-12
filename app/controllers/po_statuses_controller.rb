class PoStatusesController < ApplicationController
  before_filter :find_po_status, :only => [:edit, :update, :destroy]
  before_filter :check_query, :only => [:search]
  
  def index
    @po_statuses = PoStatus.list(params, :order => "po_statuses.order")
  end
  
  def search
    @po_statuses = PoStatus.full_text_search(params)
    return_search(@po_statuses)
  end
    
  def new
    @po_status = PoStatus.new
    render :action => :edit
  end
  
  def create
    @po_status = PoStatus.new
    save_and_show!
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = "There was a problem saving this PO Status." 
    render :action => :edit
  end
  
  def update
    save_and_show!
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = "There was a problem saving this PO Status."
    render :action => "edit"
  end

  def destroy
    @po_status.destroy
    redirect_to po_statuses_path
  end
  
  private
  def save_and_show!
    @po_status.attributes = params[:po_status]
    @po_status.save!
    flash[:notice] = "<a href=\"#{edit_po_status_path(@po_status)}\">#{@po_status.status}</a> was saved successfully at #{current_time}"
    redirect_to po_statuses_path   
  end

  def find_po_status
    @po_status = PoStatus.find(params[:id])
  end
end
