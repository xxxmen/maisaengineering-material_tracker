class RequestedLineItemsController < ApplicationController
  def create
    @request = MaterialRequest.find(params[:material_request_id])
    @item = @request.items.build(params[:requested_line_item])
    @item.save!
    render :nothing => true
  rescue ActiveRecord::RecordInvalid
    @item.valid?
    render :text => @item.errors.full_messages.join("\n"), :status => 500
  end
  
  def update
    @item = RequestedLineItem.find(params[:id])
    @item.update_attributes!(params[:requested_line_item])
    render :nothing => true
  rescue ActiveRecord::RecordInvalid
    @item.valid?
    render :text => @item.errors.full_messages.join("\n"), :status => 500
  end
  
  def destroy
    @item = RequestedLineItem.find_by_id(params[:id])
    @item.destroy if @item
    render :nothing => true
  end
end
