class CartsController < ApplicationController
  auto_complete_for :unit, :description
  auto_complete_custom_for :employee, :list_employee_names
  auto_complete_custom_for :employee, :list_requester_names

  before_filter :resource_enabled?
  before_filter :find_cart, :only => [:edit, :index, :search, :destroy, :update]
  before_filter :extract_auto_completes, :only => [:create, :update]
  skip_before_filter :login_required, :only => [:get_order]

  # Renders a CSV format of the most recent cart that was SENT
  # If none exists, renders a 404 page
  def get_order
    cart = Cart.find(:first, :conditions => ["state = ?", Cart::SENT])
    if cart
      cart.update_attributes!(:state => Cart::RECEIVED, :received_at => Time.now.to_s(:db))
      render :text => cart.return_csv
    else
      render :text => "404 Page Not Found", :status => 404
    end
  end

  def edit
  end

  #
  def resend
    @cart = Cart.find(:first, :conditions => ["state = ? AND id = ?", Cart::RECEIVED, params[:id]])
    if @cart
      @cart.received_at = nil
      @cart.state = Cart::SENT
      @cart.save!
      flash[:message] = "Cart was successfully resent to #{ENV['WAREHOUSE_NAME']}"
      redirect_to :action => "recent"
    else
      flash[:message] = "Cart has not been received by #{ENV['WAREHOUSE_NAME']} yet"
      redirect_to :action => "recent"
    end
  end

  def recent_csv
    @cart = Cart.find(params[:id], :conditions => ["state = ? OR state = ?", Cart::SENT, Cart::RECEIVED])
    render :text => @cart.return_csv, :content_type => "text/csv"
  end

  def recent
    @carts = Cart.filter(current_employee, params, params[:status])
    if params[:status] != 'all' && @carts.size == 0
      flash[:error] = "Could not find any web requests that matched the status '#{params[:status]}', redirected to 'all'" if !params[:status].blank?
      render :action => :recent, :status => 'all'
    end
  end

  def index
    @inventory_items = InventoryItem.list(params)
  end

  def search
    @inventory_items = InventoryItem.full_text_search(params)
    return_search(@inventory_items)
  end

  def recent_search
    Cart.send(:with_scope, :find => { :conditions => ["state = ? OR state = ?", Cart::SENT, Cart::RECEIVED] }) do
      @carts = Cart.full_text_search(params, :order => "carts.created_at", :sort => "DESC", :include => [:employee, :unit])
    end

    if @carts.size == 0
      flash[:error] = "There were no search results for '#{params[:q]}'"
      redirect_to(:action => :recent) and return
    else
      flash.now[:notice] = "Found #{@carts.count} results for '#{params[:q]}'"
      render(:action => :recent)
    end
  end

  def return_search(results, options={})
    if results.size == 0
      flash[:error] = "There were no search results for '#{params[:q]}'"
      redirect_to({:action => :index}.merge(options)) and return
    elsif results.size == 1 && current_employee.direct_search?
      flash[:notice] = "Found one record and redirected to your search result"
      redirect_to(:action => :edit, :id => results.to_a[0])
    else
      flash.now[:notice] = "#{refined_search} <div id='result_msg'>Found #{results.count} results for <span style='color: orangered;'>'#{params[:q]}'</span>  <a href='#' onclick=\"$('refine').toggle(); $('refine').down('input').focus(); $('result_msg').hide(); \">Filter Results</a></div>".html_safe
      render(:action => :index)
    end
  end


  def destroy
    @cart.cart_items.each do |cart_item|
      cart_item.destroy
    end
    flash[:notice] = "Your cart was cleared successfully at #{current_time}"
    redirect_to :action => "index"
  end

  def delete
    @cart = Cart.find(params[:id])
    @cart.destroy
    flash[:notice] = "Web request was successfully deleted"
    redirect_to :action => "recent"
  end

  def update
    params[:cart_items] ||= []
    params[:cart_items].each do |cart_id, attributes|
      cart_item = CartItem.find(cart_id)
      if(attributes[:quantity].to_s == "0")
        cart_item.destroy
      else
        cart_item.update_attributes!(attributes)
      end
    end

    @cart.update_attributes!(params[:cart])

    if params[:commit] == "Save and Add More Items"
      flash[:notice] = "Your web request was saved successfully"
      redirect_to carts_path and return
    end

    if @cart.cart_items.size > 0
      manual = @cart.send_request() # creates a new 'current' cart for the employee
      flash[:notice] = "The request will be submitted directly to purchasing.  <br/> This is only a draft, be sure to submit this form to request your material."
      redirect_to :controller => "material_requests", :action => :edit, :id => manual
    else
      flash[:error] = "Cannot issue this web request with no line items, please add one first"
      redirect_to :action => :edit, :id => "current"
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.to_s
    render :action => :edit
  end

  private
  def find_cart
    if params[:id].blank? || params[:id] == 'current'
      @cart = current_employee.last_cart
    else
      @cart = Cart.find(params[:id])
    end
  end

  def extract_auto_completes
    errors = []
    @cart ||= find_cart

    if params.has_key?(:unit) && params[:unit].has_key?(:description)
      unit = Unit.find_by_description(params[:unit][:description])
      if unit
        params[:cart][:unit_id] = unit.id
      else
        errors.push("Could not find unit '#{params[:unit][:description]}'")
        @cart.unit = Unit.new(:description => params[:unit][:description])
      end
    end
    if params.has_key?(:employee) && params[:employee].has_key?(:list_employee_names)
      params[:cart][:deliver_to] = params[:employee][:list_employee_names]
    end
    if params.has_key?(:employee) && params[:employee].has_key?(:list_requester_names)
      name = params[:employee][:list_requester_names].strip
      name =~ /\((\d+)\)$/
      id = $1
      employee = Employee.find_by_id(id)
      if employee
        params[:cart][:requested_by_id] = employee.id
        employee.update_attributes!(:telephone => params[:cart][:telephone]) if !params[:save_phone].blank?
      else
        errors.push("Could not find requester '#{params[:employee][:list_requester_names]}'")
        @cart.requester = Employee.new(:first_name => params[:employee][:list_requester_names], :last_name => "")
      end
    end

    if errors.size > 0
      @cart.attributes = params[:cart]
      flash.now[:error] = errors.join(', ')
      render :action => :edit and return
    end
  end
end
