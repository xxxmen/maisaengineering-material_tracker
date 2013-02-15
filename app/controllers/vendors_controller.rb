class VendorsController < ApplicationController
  before_filter :find_vendor, :only => [:edit, :update, :destroy]
  before_filter :check_query, :only => [:search]
  
  def index
    @vendors = Vendor.list(params, :order => "vendors.name")
  end
  
  def search
    @vendors = Vendor.full_text_search(params)
    return_search(@vendors)
  end
    
  def new
    @vendor = Vendor.new
    render :action => :edit
  end
  
  def create
    @vendor = Vendor.new
    save_and_show!
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = "There was a problem saving this vendor." 
    render :action => :edit
  end
  
  def update
    save_and_show!
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = "There was a problem saving this vendor."
    render :action => "edit"
  end

  def destroy
    @vendor.destroy
    redirect_to orders_path
  end
  
  private
  def save_and_show!
    @vendor.attributes = params[:vendor]
    @vendor.save!
    flash[:notice] = "<a href=\"#{edit_vendor_path(@vendor)}\">#{@vendor.name}</a> was saved successfully at #{current_time}".html_safe
    redirect_to vendors_path   
  end

  def find_vendor
    @vendor = Vendor.find(params[:id])
  end
end
