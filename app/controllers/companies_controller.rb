class CompaniesController < ApplicationController
  before_filter :find_company, :only => [:edit, :update, :destroy]
  before_filter :check_query, :only => [:search]
  def index
    @companies = Company.list(params, :order => "companies.updated_at", :sort => "desc")
  end

  def search
    @companies = Company.full_text_search(params)
    return_search(@companies)
  end

  def new
    @company = Company.new
    render :action => :edit
  end

  def create
    @company = Company.new
    save_and_show!
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = "There was a problem saving this company."
    render :action => :edit
  end

  def update
    save_and_show!
  rescue ActiveRecord::RecordInvalid
  end

  def destroy
    @company.destroy
    redirect_to companies_path
  end

  private
  def save_and_show!
    @company.attributes = params[:company]
    @company.save!
    respond_to do |wants|
      wants.html do
        flash[:notice] = msg_for("Company", @company.name, @company)
        redirect_to companies_path
      end
      wants.js
    end
  end

  def find_company
    @company = Company.find(params[:id])
  end
end