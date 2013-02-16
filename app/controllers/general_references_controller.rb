class GeneralReferencesController < ApplicationController
  before_filter :resource_enabled?
  
  def index
    @references = GeneralReference.list(params, :order => "id", :sort => "desc")
  end
  
  def search
    @references = GeneralReference.full_text_search(params)
    return_search(@references)
  end
  
  def download
    @reference = GeneralReference.find(params[:id])
    send_file @reference.reference.path
  end

  def new
    @reference = GeneralReference.new
    render :action => :edit
  end
  
  def edit
    @reference = GeneralReference.find(params[:id])
  end  
  
  def create
    @reference = GeneralReference.create!(:reference => params[:general_reference][:reference])
    flash[:notice] = "Your file was successfully saved at " + current_time
    redirect_to :action => :index
  end
  
  def update
    @reference = GeneralReference.find(params[:id])
    @reference.update_attributes!(:reference => params[:general_reference][:reference])
    flash[:notice] = "Your file was successfully saved at " + current_time
    redirect_to :action => :index
  end
  
  def destroy
    @reference = GeneralReference.find(params[:id])
    @reference.destroy
    flash[:notice] = "Your file was successfully deleted at " + current_time
    redirect_to :action => :index
  end
  
  def return_search(results)
    if results.size == 0
      flash[:error] = "There were no search results for '#{params[:q]}'"
      redirect_to(:action => :index) and return
    else
      flash.now[:notice] = "Found #{results.size} results for '#{params[:q]}'"
      render(:action => :index)
    end
  end  
end
