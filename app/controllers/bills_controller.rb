class BillsController < ApplicationController
  def index
    @bills = Bill.list(params)
  end

  def review
  	@bill = Bill.find(params[:id])
  	@bill.reviewed_by_id = current_employee.id
  	@bill.save!
  	render :json => {:success => true}.to_json
  end

  def unreview
  	@bill = Bill.find(params[:id])
  	@bill.reviewed_by_id = nil
  	@bill.save!
  	render :json => {:success => true}.to_json
  end

  def approve
  	@bill = Bill.find(params[:id])
  	@bill.approved_by_id = current_employee.id
  	@bill.save!
  	render :json => {:success => true}.to_json
  end

  def disapprove
  	@bill = Bill.find(params[:id])
  	@bill.approved_by_id = nil
  	@bill.save!
  	render :json => {:success => true}.to_json
  end

  def mail_for_quote
    @bill = Bill.find(params[:id])
    @reply_to = current_employee.email.blank? ? "no-reply@#{ENV['MAIL_DOMAIN']}" : current_employee.email
  end

  def deliver_mail_for_quote
    BillMailer.send_as_html("quote", params[:id], params)
    flash[:notice] = "BOM ##{params[:id]} was send out for a quote"
    redirect_to :action => :index
  end

  def create
    @bill = current_employee.bills.create!
    @bill_item = @bill.bill_items.create!(params[:bill_item])
    redirect_to :action => :edit, :id => @bill
  end

  def new
    @bill = Bill.new
    @bill_item = @bill.bill_items.build
  end

  def edit
    @bill = Bill.find(params[:id])
  end
end

