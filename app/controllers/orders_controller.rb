class OrdersController < ApplicationController
  layout "layouts/application", :except => :pdf

  before_filter :resource_enabled?

  before_filter :find_order, :only => [:edit, :update, :destroy]  
  before_filter :check_query, :only => [:search]
  before_filter :extract_unit_for_measure, :only => [:auto_complete_for_unit_for_measure_name]
  before_filter :extract_company_name, :only => [:auto_complete_custom_for_company_list_companies_for_autocomplete]
  before_filter :extract_employee_name, :only => [:auto_complete_custom_for_employee_list_employee_names]
  
  
  auto_complete_for :vendor, :name
  auto_complete_for :unit, :description
  auto_complete_custom_for :employee, :list_employee_names  
  auto_complete_custom_for :company, :list_companies_for_autocomplete
  auto_complete_for :unit_for_measure, :name

  def index
    Order.filter(params, current_employee) do
      if current_employee.receiving?
        # DONTCHANGE: Sort order by date created was requested by Vince on 11/02/2007
        @orders = Order.list(params, :include => [:vendor, :unit, :status, :ordered_line_items], :order => "purchase_orders.created DESC, purchase_orders.id", :sort => "desc")
      else
        @orders = Order.list(params, :include => [:vendor, :unit, :status], :order => "purchase_orders.created DESC, purchase_orders.id", :sort => "desc")
      end
    end
  end
      
  def search
    Order.filter(params, current_employee) do
      params[:q] += " " + params[:refined] if params[:refined]
      # DONTCHANGE: Sort order by date created was requested by Vince on 11/02/2007
      @orders = Order.search_with_year(params, :order => "purchase_orders.created DESC, purchase_orders.id", :sort => "DESC")
      return_search
    end
  end
  
  def search_line_items
    @order = Order.find(params[:id])
    OrderedLineItem.filter(params[:id]) do
      @ordered_line_items = OrderedLineItem.full_text_search(params, :order => "line_item_no")
      return_search_line_items
    end
  end
  
  def sort_line_items
    @order = Order.find(params[:id], :include => :ordered_line_items)
    if request.post?
      @order.ordered_line_items.each do |item|
        item.line_item_no = params['line_items'].index(item.id.to_s) + 1
        item.save
      end
      render :nothing => true
    end
  end
  
  def email
    @order = Order.find(params[:id])
    # DAVE: if the order has only one line item, and descriptions match, confirm with user first
    if @order.ordered_line_items.size == 1
      desc = @order.description || ""
      desc = desc.strip
      line = @order.ordered_line_items[0].description || ''
      line = line.strip
      @alert_user = desc.include?(line)
    else
      @alert_user = false
    end
  end
  
  def clear_reminders
    @order = Order.find(params[:id])
    @order.reminders.clear
    redirect_to :action => 'reminders', :id => @order.id
  end
  
  def reminders    
    @order = Order.find(params[:id])
    if(@order.date_eta.blank?)
      flash[:error] = "ETA Must be set before you can send reminders."
      redirect_to :back and return
    end
    
    @reminders = @order.reminders.find(:all, :order => 'reminders.send_reminder_on ASC')
  end
  
  def remove_reminder
    @reminder = Reminder.find(params[:id])
    @order = @reminder.order
    
    @reminder.destroy
    
    flash[:notice] = "Successfully deleted the Reminder."
    
    redirect_to :action => 'reminders', :id => @order.id
  end
  
  ##
  #   Sends an email for the reminder with id = params[:id].
  ##
  def send_reminder
    @reminder = Reminder.find(params[:id])
    @order = @reminder.order
    
    @reminder.send_email(params)
    
    flash[:notice] = "Your email was successfully sent at #{current_time}"
    redirect_to :action => :reminders, :id => @order
  end
  
  def create_reminders
      successful, message = Reminder.create_reminders_for_order(
          params[:id], 
          params[:email_to], 
          params[:notes], 
          params[:reminder]
      )
      
      if successful
          flash[:notice] = message
          redirect_to edit_order_path(:id => params[:id])
      else
          flash[:error] = message
	      redirect_to :action => 'reminders', :id => params[:id]  
      end
    # @order = Order.find(params[:id])
    # 
    # icount = 0
    # if(params['reminder']['date_of'] == '1')
    #     @order.reminders << Reminder.create(:po_id => @order.id, 
    #                                     :email_to => params[:email_to],
    #                                     :notes => params[:notes],
    #                                     :send_reminder_on => @order.date_eta)
    #     icount += 1
    # end
    # if(!params['reminder']['custom_date'].blank?)
    #     @order.reminders << Reminder.create(:po_id => @order.id, 
    #                                     :email_to => params[:email_to],
    #                                     :notes => params[:notes],
    #                                     :send_reminder_on => params['reminder']['custom_date'])
    #                                             
    #     icount += 1
    # end
    # [1,2,3,4,8].each do |wk|
    #   if(params['reminder']['week_' + wk.to_s + '_after'] == '1')
    #     @order.reminders << Reminder.create(:po_id => @order.id, 
    #                                     :email_to => params[:email_to],
    #                                     :notes => params[:notes],
    #                                     :send_reminder_on => @order.date_eta + wk.weeks)
    #     icount += 1
    #   end
    #   
    #   if(params['reminder']['week_' + wk.to_s + '_before'] == '1')
    #     @order.reminders << Reminder.create(:po_id => @order.id, 
    #                                     :email_to => params[:email_to],
    #                                     :notes => params[:notes],
    #                                     :send_reminder_on => @order.date_eta - wk.weeks)
    #     icount += 1
    #   end
    # end
    # if(icount > 0)
    #   flash[:notice] = icount.to_s + " Reminders Set for Order #{@order.po_no}"
    #   redirect_to :action => 'edit', :id => @order  
    # else
    #   flash[:error] = "No Reminders Set"
    #   redirect_to :action => 'reminders', :id => @order  
    # end
    
#    @order = Order.find(params[:id])
#    # DAVE: if the order has only one line item, and descriptions match, confirm with user first
#    if @order.ordered_line_items.size == 1
#      desc = @order.description || ""
#      desc = desc.strip
#      line = @order.ordered_line_items[0].description || ''
#      line = line.strip
#      @alert_user = desc.include?(line)
#    else
#      @alert_user = false
#    end
  end
  
  def deliver
    @order = Order.find(params[:id])
    params[:from] = current_employee.name_and_email unless current_employee.email.blank?
    if params.has_key?(:autoprint)
      if params[:email].blank?
        params[:email] = "xpprint_bp@telaeris.com"
      else
        params[:email] += ", xpprint_bp@telaeris.com"
      end
    end
    respond_to do |wants|
      wants.html do
        @order.activity ||= ""
        @order.activity += "* EMAIL TO #{params[:email]} ON #{Date.today.to_s(:long)}\n"
        @order.save
        RequestMailer.send_as_html("order_for_fifth", @order, params)
        flash[:notice] = "Your email was successfully sent at #{current_time}"
        redirect_to :action => :edit, :id => @order
      end
      wants.js do
        preview = RequestMailer.preview('order_for_fifth', @order, params)
        render :update do |page|
          page.replace_html "preview", preview.gsub('Subject:', '<br />Subject:').gsub('Mime-Version:', '<br />Mime-Version:')
          page['deliver_form'].hide
          page['full_preview'].show
        end
      end
    end
  end
      
  def edit  
    @unit_description = @order.unit.description      
    @order.format_description!


    # For the new ordered line item in the lightbox
    @ordered_line_item ||= OrderedLineItem.new
  end  
    
  def new
    @unit_description = ""
    if params.has_key?(:tracking)
      @order = current_employee.new_order(:tracking => params[:tracking], :description => params[:description])
    elsif params.has_key?(:order_id)
      dup = Order.find_by_id(params[:order_id])
      if dup
        @order = current_employee.new_order(:unit_id => dup.unit_id, :turnaround_year => dup.turnaround_year, :status_id => dup.status_id,
                                            :description => dup.description, :work_orders => dup.work_orders, :deliver_to => dup.deliver_to,
                                            :vendor_id => dup.vendor_id)
      else
        @order = current_employee.new_order
      end
    else
      @order = current_employee.new_order      
    end
    @order.group_id = current_employee.get_group	
    # BP Carson wants it set to ordered automatically.
    @order.status_id = PoStatus.find(:first, :order => "po_statuses.order asc").id
    
    render :action => :edit
  end
    
  def create_ordered_line_item
    @order = Order.find(params[:id])
    line_item = @order.ordered_line_items.create!(params[:ordered_line_item])
    flash[:notice] = "Line Item saved successfully at " + Time.now.strftime("%I:%M%p on %m/%d/%y")
    
    per_page = OrderedLineItem::PERPAGE
    total_count = @order.ordered_line_items.count
    page = total_count.to_i / per_page.to_i
    
    # handle edge cases, like 20th item
    if total_count % per_page != 0
      page = page + 1
    end
    
    redirect_to :action => :edit, :id => @order, :p => page
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "An ordered line item must have a description and ordered quantity"
    redirect_to :action => "edit", :id => @order.id, :ordered_line_item => params[:ordered_line_item]
  end
  
  def update_ordered_line_item
    @ordered_line_item = OrderedLineItem.find(params[:id])
    @order = @ordered_line_item.order
    if @ordered_line_item.update_attributes_with_splitting(params[:ordered_line_item])
        flash[:notice] = "Saved line item successfully"
        flash[:line_items] = "Saved line item ##{@ordered_line_item.line_item_no} successfully"
        # edit
        redirect_to :action => :edit, :id => @ordered_line_item.order.id
    else
      flash[:error] = "Error saving line item ##{@ordered_line_item.line_item_no}: #{@ordered_line_item.errors.full_messages.join(', ')}"
      render :action => :edit
    end
  end

  def destroy_ordered_line_item
    @ordered_line_item = OrderedLineItem.find(params[:id])
    @ordered_line_item.destroy
    # @order = @ordered_line_item.order
    flash[:notice] = "Deleted line item ##{@ordered_line_item.line_item_no} successfully"
    flash[:line_items] = flash[:notice]
    redirect_to :action => :edit, :id => @ordered_line_item.order.id
  end
  
  def create
    @order = Order.new
    if params[:unit]
      if params[:unit][:description]
        @order.unit_description = params[:unit][:description]
      end
    end
    if params[:employee]
      if params[:employee][:list_employee_names]
        @order.deliver_to = params[:employee][:list_employee_names]
      end
    end
    if params.include?(:vendor)
      vendor = Vendor.find_by_name(params[:vendor][:name])
      params[:order][:vendor_id] = vendor.id if vendor
    end
    save_and_show!
  rescue ActiveRecord::RecordInvalid
    errors = "Was unable to save this order due to validation errors"
    if params[:unit].blank? || params[:unit][:description].blank?
      errors = "Unit cannot be blank"
    elsif @order.unit_id.blank?
      errors = "Could not find unit '" + params[:unit][:description] + "'"
    end
    flash[:error] = errors
    render :action => "edit"
  end
  
  def update
    if params[:unit]
      if params[:unit][:description]
        @order.unit_description = params[:unit][:description]
      end
    end
    if params[:employee]
      if params[:employee][:list_employee_names]
        @order.deliver_to = params[:employee][:list_employee_names]
      end
    end
    if params.include?(:vendor)
      vendor = Vendor.find_by_name(params[:vendor][:name])
      params[:order][:vendor_id] = vendor.id if vendor
    end
    
    save_and_show!
    # Change the group of all related material requests
    if not @order.material_requests.empty?
    	@order.material_requests.each do |material_request|
    		material_request.group = @order.group
    		material_request.save!
    	end
    end
  rescue ActiveRecord::RecordInvalid    
  	@order.format_description!
    
    # For the ordered line items list, sort by line item number
    OrderedLineItem.filter(@order.id) do
      @ordered_line_items = OrderedLineItem.list(params, :order => "line_item_no")
    end
    # For the new ordered line item in the lightbox
    @ordered_line_item ||= OrderedLineItem.new
    # For the new ordered line item in the lightbox
#    @ordered_line_item ||= OrderedLineItem.new
  	flash[:error] = "There was a problem saving this record: #{@order.errors.full_messages}"
  	edit 
  	render :action => 'edit'
  end

  def unarchive
  	@order = Order.find(params[:id])
  	if(!current_employee.admin?)
	    errors = "Must be an Admin to unarchive Orders"
	    flash[:error] = errors
    	render :action => "edit"
	else
		@order.archived = true
		@order.save!
		flash[:error] = "Order #{@order.po_no} unarchived successfully at " + Time.now.strftime("%I:%M%p on %m/%d/%y")
		
		redirect_to :action => 'edit'
    end
  end
  def archive
  	@order = Order.find(params[:id])
  	if(!current_employee.admin?)
	    errors = "Must be an Admin to archive Orders"
	    flash[:error] = errors
    	render :action => "edit"
	else
		@order.archived = true
		@order.save!
		flash[:error] = "Order #{@order.po_no} archived successfully at " + Time.now.strftime("%I:%M%p on %m/%d/%y")
		
		redirect_to :action => "index"
    end
  end

  def destroy
    @order.destroy
    redirect_to orders_path
  end
    
  def date_convert(date)
    if(date.blank?) 
      return ""
    end

    return date.strftime("%m/%d/%Y")

  end
  def edit_line_item
    @ordered_line_item = OrderedLineItem.find(params[:id], :include => :order)
    
    # @order = @ordered_line_item.order
    json = {}
    if @ordered_line_item
        json[:success] = true
        json[:record] = @ordered_line_item.to_json_data
        json[:record][:issued_date] = date_convert(json[:record][:issued_date])
        json[:record][:date_received] = date_convert(json[:record][:date_received])
        json[:record][:date_back_ordered] = date_convert(json[:record][:date_back_ordered])
        
    else
        json[:success] = false 
    end
    logger.info json.inspect
    render :json => json.to_json
  end
    
  def edit_line_items
    @order = Order.find(params[:id])
    OrderedLineItem.filter(@order.id) do
      @ordered_line_items = OrderedLineItem.list(params, :order => "line_item_no")
    end
    @ordered_line_item ||= OrderedLineItem.new
    @ordered_line_item.description = params[:description] if params[:description]
    @ordered_line_item.quantity_received = params[:qty_recd] if params[:qty_recd]
    @ordered_line_item.quantity_ordered = params[:qty_ordered] if params[:qty_ordered]
    @ordered_line_item.date_back_ordered = params[:bo_date] if params[:bo_date]
    @ordered_line_item.date_received = params[:recd_date] if params[:recd_date]
  end
    
  def save_line_item
    @ordered_line_item = OrderedLineItem.find(params[:id])
    @ordered_line_item.attributes = params[:ordered_line_item]
    @ordered_line_item.save!
    flash[:notice] = "Line Item saved successfully at " + current_time
    redirect_to :action => "edit_line_item", :id => @ordered_line_item
  end
  
  def mark_line_item_as_received
    @ordered_line_item = OrderedLineItem.find(params[:id])
    @ordered_line_item.mark_as_received
    @ordered_line_item.save

    render :update do |page|
      page.replace_html dom_id(@ordered_line_item, "quantities"), @ordered_line_item.quantities_for_list
      page.replace_html dom_id(@ordered_line_item, "date_received"), Date.today.strftime('%m/%d/%y')
      
      
      page.replace_html "po_status", options_for_select(PoStatus.list_status, @ordered_line_item.order.status_id)
      page["order_completed"].checked = "1"  if @ordered_line_item.order.completed
    end
  end
        
  def mark_remaining_as_received
      @order = Order.find(params[:id])
      @order.mark_remaining_as_received
      flash[:notice] = "All remaining line items were marked as received."
      flash[:line_items] = "All remaining line items were marked as received."
    
      redirect_to :action => (params[:redirect] || "edit")
  end

  def mark_remaining_as_issued
      @order = Order.find(params[:id])
      issued_to_name = params[:ordered_line_item][:issued_to_name]
      issued_to_company = params[:ordered_line_item][:issued_to_company]
      issued_date = params[:ordered_line_item][:issued_date]
      messages = @order.mark_remaining_as_issued(issued_to_name, issued_to_company, issued_date)
      
      if messages.blank?
        flash[:notice] = "All remaining line items were marked as issued."
        flash[:line_items] = "All remaining line items were marked as issued."
      else
        flash[:error] = "Error with issuing. Please check the following line items: #{messages.join(', ')}"
        flash[:line_items] = "Error with issuing. Please check the following line items: #{messages.join(', ')}"
      end
    
      redirect_to :action => (params[:redirect] || "edit")
  end

  
  def set_location
    @order = Order.find(params[:id])
    @order.location = params[:order][:location]
    @order.issued_to_history ||= ""
    # @order.issued_to_history = "#{Date.today.to_s(:db)}: #{current_employee.full_name}: Location : #{params[:order][:location]}" + "\n" + @order.issued_to_history
    @order.issued_to_history = "#{Date.today.to_s(:db)}: Location : #{params[:order][:location]} (#{current_employee.full_name})" + "\n" + @order.issued_to_history
    @order.save!
    @order.set_status_as_received
  end
  
  def print
    order = Order.find(params[:id])
    data = `#{ENV['REPORT_USER_COMMAND']} /usr/local/reportman/printreptopdf -paramPSEARCHID=#{params[:id].to_s} #{Rails.root}/reports/print_purchase_order_linux.rep 2>> #{Rails.root}/stderr.txt`

    send_data(data, :type => "application/pdf", :filename => "order_#{order.po_no}.pdf")
  end
  
  def select_pos
    if request.get?
      Order.filter(params, current_employee) do
        # DONTCHANGE: Sort order by date created was requested by Vince on 11/02/2007
        @orders = Order.search_with_year(params.merge(:c => 1000), :order => "purchase_orders.created DESC, purchase_orders.id", :sort => "DESC")
        @orders = @orders.to_a
      end
    end
    if request.post?
      @orders = Order.ids_for_pos(params[:psearchids])
      ponos = @orders.join(",")
      if params[:commit] == "Print Selected POs"
        data = `#{ENV['REPORT_USER_COMMAND']} /usr/local/reportman/printreptopdf -paramPSEARCHID=\"#{ponos}\" #{Rails.root}/reports/print_purchase_order_linux.rep 2>> #{Rails.root}/stderr.txt`
        send_data(data, :type => "application/pdf", :filename => "purchase_orders.pdf")
      else
        redirect_to :action => "email_pos", :id => ponos
      end
    end
  end
    
  def email_pos
    ids = params[:id].split(',')
    @orders = Order.find(ids)
    
    if request.post?
      params[:from] = current_employee.name_and_email unless current_employee.email.blank?
      if params.has_key?(:autoprint)
        if params[:email].blank?
          params[:email] = "xpprint_bp@telaeris.com"
        else
          params[:email] += ", xpprint_bp@telaeris.com"
        end
      end
      
      respond_to do |wants|
        
        wants.html do
          @orders.each do |order|
            order.activity ||= ""
            order.activity += "* EMAIL TO #{params[:email]} ON #{Date.today.to_s(:long)}\n"
          end
          RequestMailer.send_as_html("orders_for_fifth", @orders, params)
          flash[:notice] = "Your email was successfully sent at #{current_time}"
          redirect_to :action => :index
        end
        
        wants.js do
          preview = RequestMailer.preview('orders_for_fifth', @orders, params)
          render :update do |page|
            page.replace_html "preview", preview.gsub('Subject:', '<br />Subject:').gsub('Mime-Version:', '<br />Mime-Version:')
            page['deliver_form'].hide
            page['full_preview'].show
          end
        end
        
      end # end respond_to
    end # end request.post?   
  end
        
  private
  def save_and_show!
    @order.attributes = params[:order]
    
    if @order.new_record?
      if @order.tracking.blank?
        @order.tracking = Order.newest_tracking
      end
      @order.save!
    else
      @order.save!  
    end
        
    # process line items for requesters
    if current_employee.requesting?
      (1..params[:count].to_i).each do |item_no|
        @order.create_or_update_line_item(item_no, params["ordered_line_item_" + item_no.to_s])
      end
      
      if params[:ordered_line_item_1] && params[:action] == "create"
        @order.description = params[:ordered_line_item_1][:description]
        @order.save
      end
    end
        
    respond_to do |wants|
      wants.html do 
        flash[:notice] = "Order ##{@order.po_no} saved successfully at " + current_time
        if @order.status_set_to_fully_received
          flash[:notice] = "##{@order.po_no} has been fully received"
        end
        redirect_to edit_order_path(@order) 
      end
      wants.js do
        @order.set_status_as_received
        render(:update) do |page|
          page.replace_html :confirmation, :inline => "Location &amp; History saved successfully."
          page.visual_effect :appear, :confirmation, :duration => 0.1
          page.visual_effect :highlight, :confirmation
          page.delay(4) do
            page.visual_effect :fade, :confirmation, :duration => 0.1
            page.replace_html :confirmation, ""
          end
        end
      end
    end
  end
  
  def find_order
    @warehouse = current_employee.warehouse?(true) || current_employee.requesting?
    @requesting = current_employee.requesting?
    @order = Order.find(params[:id], :include => :ordered_line_items)
  end
  
  def return_search
    year_string = params[:year].blank? ? "" : "for <span style='color: orangered;'>" + params[:year] + "</span>".html_safe
    
    if @orders.size == 0
      flash[:error] = "There were no search results for <span style='color: red;'>'#{params[:q]}'</span> #{year_string}".html_safe
      #redirect_to orders_path(params) and return  -- Not working in Rails 3 not route mateches search
      redirect_to action: :index and return
    elsif @orders.size == 1 && !current_employee.direct_search?
      flash.now[:notice] = "Found 1 purchase order"
      render :action => "index"
    elsif @orders.size == 1 && current_employee.direct_search?
      flash[:notice] = "Found 1 purchase order and redirected to search result"
      redirect_to edit_order_path(@orders.to_a[0])
    else
      flash.now[:notice] = "#{refined_search} <div id='result_msg'>Found #{@orders.size} results for <span style='color: orangered;'>'#{params[:q]}'</span> #{year_string}  <a href='#' onclick=\"$('refine').toggle(); $('refine').down('input').focus(); $('result_msg').hide(); \">Filter Results</a></div>".html_safe
      render :action => "index"
    end
  end
  
  def return_search_line_items
    if @ordered_line_items.size == 0
      flash[:error] = "There was no search results for <span style='color: red;'>'#{params[:q]}'</span>"
      redirect_to :action => :edit_line_items, :id => @order
    else
      @ordered_line_item ||= OrderedLineItem.new
      @ordered_line_item.description = params[:description] if params[:description]
      @ordered_line_item.quantity_received = params[:qty_recd] if params[:qty_recd]
      @ordered_line_item.quantity_ordered = params[:qty_ordered] if params[:qty_ordered]
      @ordered_line_item.date_back_ordered = params[:bo_date] if params[:bo_date]
      @ordered_line_item.date_received = params[:recd_date] if params[:recd_date]
      flash.now[:notice] = "Found #{@ordered_line_items.size} results for <span style='color: red;'>'#{params[:q]}'</span>"
      render :action => :edit_line_items
    end
  end
  
  def refined_search
    "<form id='refine' style='display: none; text-align: center;'>" +
      "<input type='hidden' name='q' value='#{params[:q]}' />" +
      "<input type='hidden' name='year' value='#{params[:year]}' />" +
      "<input type='text' name='refined' style='width: 200px;' />" +
      "<input type='submit' value='Filter Results' />" +
    "</form>".html_safe
  end
  
  def extract_unit_for_measure
    params[:unit_for_measure] ||= {}
    params[:unit_for_measure][:name] ||= params[:ordered_line_item][:unit_of_measure]
  end
  
  def extract_company_name
    params[:company] ||= {}
    params[:company][:list_companies_for_autocomplete] ||= params[:ordered_line_item][:issued_to_company]
  end

  def extract_employee_name
    params[:employee] ||= {}
    params[:employee][:list_employee_names] ||= params[:ordered_line_item][:issued_to_name]
  end  
end
