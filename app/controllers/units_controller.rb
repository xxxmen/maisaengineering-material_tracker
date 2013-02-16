class UnitsController < ApplicationController
  before_filter :find_unit, :only => [:edit, :update, :destroy]  
  before_filter :check_query, :only => [:search]
    
  def index
    @units = Unit.list(params, :order => "units.updated_at", :sort => "desc")
  end
  
  def search
    @units = Unit.full_text_search(params)
    return_search(@units)
  end
    
  def new
    @unit = Unit.new
    render :action => :edit
  end
            
  def create
    @unit = Unit.new
    save_and_show!
  rescue ActiveRecord::RecordInvalid
    render :action => "edit"
  end
  
  def update
    save_and_show!
  rescue ActiveRecord::RecordInvalid
  end

  def destroy
    @unit.destroy
    redirect_to units_path
  end
  
  private
  def save_and_show!
    @unit.attributes = params[:unit]
    @unit.save!
    respond_to do |wants|
      wants.html do
        flash[:notice] = msg_for("Unit", @unit.description, @unit)
        redirect_to units_path
      end
      wants.js
    end
  end
  
  def find_unit
    @unit = Unit.find(params[:id])
  end
  
end
