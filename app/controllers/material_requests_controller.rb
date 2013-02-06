require 'csv'

class MaterialRequestsController < ApplicationController
  before_filter :resource_enabled?
  before_filter :find_material_request, :only => [:create, :edit, :update, :quote_comparison]
  before_filter :check_query, :only => [:search]
  before_filter :check_draft, :only => [:create, :update]
  before_filter :extract_auto_completes, :only => [:create, :update]
  before_filter :extract_unit_for_measure, :only => [:auto_complete_for_unit_for_measure_name]
  skip_before_filter :login_required, :only => [:quote, :quote_file, :quote_discuss]
  before_filter :access_key_required, :only => [:quote, :quote_file, :quote_discuss]
  before_filter :get_list_of_reference_number_types, :only => [:new, :create, :edit, :update]

  auto_complete_for :unit, :description
  auto_complete_for :vendor, :name
  auto_complete_for :material_request, :work_orders
  auto_complete_for :reference_number_type, :name
  auto_complete_for :order, :po_no
  auto_complete_custom_for :employee, :list_employee_names
  auto_complete_custom_for :employee, :list_requester_names

  def index
    @material_requests = MaterialRequest.for_employee(current_employee, params, params[:status])
  end

  def edit
    find_suggested_vendor
  end

  def quote_comparison
  end

  def get_attachment
    material_request = MaterialRequest.find(params[:id])
    send_file material_request.attached_file_path, :filename => material_request.attachment_file_name
  end

  def clear_attachment
    material_request = MaterialRequest.find(params[:id])
    material_request.attachment.clear
    material_request.save!

    flash[:notice] = "Attachment Cleared"
    redirect_to :action => "edit", :id => material_request.id
  end

  def sort
    @material_request = MaterialRequest.find(params[:id], :include => :items)
    if request.post?
      @material_request.items.each do |item|
        item.item_no = params['line_items'].index(item.id.to_s) + 1
        item.save
      end
      render :nothing => true
    end
  end

  def filter_vendors
    if params[:query].blank?
      @vendors = Vendor.find(:all, :order => :name)
    else
      @vendors = Vendor.search(:q => '*' + params[:query] + '*', :limit => 2000, :order => :name)
    end
    render :update do |page|
      page.replace "select", :partial => "select_vendor", :locals => { :vendors => @vendors }
    end
  end

  def new_quote
    @material_request = MaterialRequest.find(params[:id])
    if request.post?
      @vendor = Vendor.find_by_name(params[:vendor][:name])
      if @vendor

        @quote = Quote.find_or_create(@material_request, @vendor,params[:request])
        redirect_to :action => "quote", :id => @material_request, :access_key => @vendor.access_key, :vendor_id => @vendor.id, :new_quote => @quote.delta
      else
        flash[:error] = "Could not find the vendor with name: '#{params[:vendor][:name]}'"
        redirect_to :action => "new_quote"
      end
    end
  end

  def email_quote
    @material_request = MaterialRequest.find(params[:id])
    find_suggested_vendor
    @vendors = Vendor.find(:all, :order => :name)
    @vendor_groups = VendorGroup.find(:all, :order => :name)
    @vendor_groups_for_js = Hash.new
    @vendor_groups.each do |v|
        vendors = []
        v.vendors.each {|vendor| vendors.push vendor.email.to_s + " (" + vendor.id.to_s + ")" }
        @vendor_groups_for_js["vendor_group_#{v.id}"] = vendors
    end

    if request.post?
      all_emails = []
      params[:emails] ||= {}


      @vendors = Vendor.find(params[:emails].keys)
      @vendors.each do |vendor|
        options = {}
        options[:message] = params[:message]
        options[:email] = params[:emails][vendor.id.to_s]
        options[:from] = current_employee.name_and_email
        all_emails.push(options[:email])

        if params[:save_emails] && options[:email].to_s != vendor.email
          vendor.update_attributes(:email => options[:email])
          vendor.save
        end

        # Finds or creates the Quote
        quote = Quote.find_or_create(@material_request, vendor, params[:request])
        # Attaches each files to this quote.
        quote.uploaded_quote_attachments = params[:uploaded_quote_attachments]

        RequestMailer.send_as_html('quote_for_vendor', @material_request, vendor, quote, options)


      end

      if @material_request.planner && !@material_request.planner.email.blank?

        RequestMailer.send_as_html('quote_for_vendor',
        	@material_request,
        	@material_request.planner,
          nil,
        	{
        		:message => params[:message],
          		:email => @material_request.planner.email,
          		:from => current_employee.name_and_email
          	}
        )
        all_emails.push(@material_request.planner.email)
      end

      @material_request.current_employee_id = current_employee.id
      @material_request.quote_requested = "1"
      @material_request.activity ||= ""
      @material_request.activity += "* QUOTE SENT #{all_emails.join(', ')} ON #{Date.today.to_s(:long)}\n"
      @material_request.save

      flash[:notice] = "Quote Requests successfully sent"
      redirect_to :action => :edit, :id => @material_request
    end
  end

  def mail_to_purchaser
    @material_request = MaterialRequest.find(params[:id])
    if @material_request.purchaser && !@material_request.purchaser.email.blank?
      @email = @material_request.purchaser.email
    end
    @vendor = Vendor.find_by_name(@material_request.suggested_vendor)
    if @vendor
      @vendor_email = @vendor.email.blank? ? "No email found" : @vendor.email
      @vendor_name = @vendor.name || ""
    else
      @vendor_email = ""
      @vendor_name = ""
    end
  end

  def deliver_mail_to_purchaser
    @material_request = MaterialRequest.find(params[:id])
    params[:from] = current_employee.name_and_email
    params[:message] = params[:message].gsub(/\r\n/, '<br>')
    RequestMailer.send_as_html("request_for_purchaser", @material_request, params)

    @material_request.activity ||= ""
    @material_request.activity += "* EMAIL TO #{params[:email]} ON #{Date.today.to_s(:long)}\n"
    @material_request.save

    flash[:notice] = "Your email was successfully sent at #{current_time}"
    redirect_to :action => :edit, :id => @material_request
  end

  def acknowledge
    @material_request = MaterialRequest.find(params[:id])
    @material_request.current_employee_id = current_employee.id
    @material_request.acknowledged = 1
    @material_request.save
    flash[:notice] = "This material request has been acknowledged by you"
    redirect_to edit_material_request_path(@material_request)
  end

  def search
    @material_requests = MaterialRequest.search(params, :include => [:requester, :unit, :items])
    if current_employee.admin? || current_employee.purchasing? || current_employee.warehouse? || current_employee.warehouse_admin?
      return_search(@material_requests, params)
    else
      return_search(@material_requests, params)
    end
  end

  def new
    @material_request = current_employee.material_requests.build({
    	:current_employee_id => current_employee.id,
    	:telephone => current_employee.telephone
    })

    # This really should be inside the model in a #duplicate_request method...
    if params[:material_request_id] && (dup = MaterialRequest.find_by_id(params[:material_request_id]))
      @material_request.attributes = {
      	:unit_id => dup.unit_id,
      	:year => dup.year,
      	:requested_by_id => dup.requested_by_id,
      	:work_orders => dup.work_orders,
      	:deliver_to => dup.deliver_to,
      	:suggested_vendor => dup.suggested_vendor,
		:purchaser_id => dup.purchaser_id,
		:planner_id => dup.planner_id,
		:telephone => dup.telephone,
		:reference_number_type => dup.reference_number_type,
		:reference_number => dup.reference_number,
		:stage_location => dup.stage_location,
		:notes => dup.notes
	  }

      if params[:duplicate_items] == 'true'
	      dup.items_sorted.each do |item|
    	  	new_item = @material_request.items.build(item.attributes)
    	  	new_item.id = item.item_no
    	  end
      end
    end

    if params[:basket_id] && (basket = Basket.find(params[:basket_id]))
      basket.basket_items.each_with_index do |basket_item, index|
        item = @material_request.items.build({
        	:item_no => index + 1,
        	:quantity => basket_item.quantity,
        	:unit_of_measure => basket_item.inventory_item.unit_of_measure,
        	:material_description => basket_item.inventory_item.description
        })
        item.id = item.item_no
      end
    end
    @material_request.group_id = current_employee.get_group

    render :action => :edit
  end

  def duplicate
  	redirect_to	new_material_request_path({
  		:material_request_id => params[:id],
  		:duplicate_items => 'false'
  	})
  end

  def duplicate_with_items
  	redirect_to	new_material_request_path({
  		:material_request_id => params[:id],
  		:duplicate_items => 'true'
  	})
  end

  def new_from_bom
    @material_request = current_employee.material_requests.build(:current_employee_id => current_employee.id, :telephone => current_employee.telephone)
    if params[:material_request_id] && (dup = MaterialRequest.find_by_id(params[:material_request_id]))
      @material_request.attributes = { :unit_id => dup.unit_id, :year => dup.year, :requested_by_id => dup.requested_by_id,
                                       :work_orders => dup.work_orders, :deliver_to => dup.deliver_to, :suggested_vendor => dup.suggested_vendor,
                                       :purchaser_id => dup.purchaser_id, :planner_id => dup.planner_id }
    end

    if params[:basket_id] && (basket = Basket.find(params[:basket_id]))
      basket.basket_items.each_with_index do |basket_item, index|
        item = @material_request.items.build(:item_no => index + 1, :quantity => basket_item.quantity, :unit_of_measure => basket_item.inventory_item.unit_of_measure, :material_description => basket_item.inventory_item.description)
        item.id = item.item_no
      end
    end


    @material_request.unit = Unit.find_by_description('UNSPECIFIED')
    @material_request.save!

    items = ActiveSupport::JSON.decode(params[:item])
    @material_request.update_with_new_items(items)

    render :json => {:location => '/material_requests/' + @material_request.id.to_s + '/edit/' ,:success => true}.to_json
  end

  def create
    @material_request.update_with_items(params[:material_request], params[:item])
    flash[:notice] = msg_for("Request", @material_request.tracking, @material_request)
    redirect_to edit_material_request_path(@material_request)
  rescue ActiveRecord::RecordInvalid
    @material_request.items.destroy_all
    @item = @material_request.items.build
    @item.id = 0
    @material_request.group_id = current_employee.get_group
    flash[:error] = "There were some errors with this material request: #{@material_request.errors.full_messages.join(', ')}"
    render :action => "edit"
  end

  def update
    @material_request.current_employee_id = current_employee.id
    params[:material_request][:uploaded_material_request_attachments] = params[:uploaded_material_request_attachments]
    @material_request.update_with_items(params[:material_request], params[:item])
    # Change the group of all related orders
    if not @material_request.orders.empty?
    	@material_request.orders.each do |order|
    		order.group = @material_request.group
    		order.save!
    	end
    end

    @material_request.reload
    @material_request.delete_default_items! if params[:commit] != "Delete Items"

    if params[:commit] == "Assign To"
      @material_request.completed = true
      @material_request.save
      params[:new_order] ||= {}
      order = Order.find_by_po_no(params[:order][:po_no]) if !params[:order][:po_no].blank?
      if !order
        order = Order.create_from(@material_request, params[:new_order].keys, params[:order][:po_no])
      else
        order.update_from(@material_request, params[:new_order].keys)
      end
      redirect_to edit_order_path(order.id) and return
    elsif params[:commit] == "Delete Items"
      if @material_request.items.count - params[:new_order].keys.size.to_i == 0
        flash[:error] = "We could not delete your line item  because a request must have at least one"
      else
        params[:new_order].keys.each do |line_item_id|
          line = RequestedLineItem.find(line_item_id)
          line.destroy
        end
        flash[:notice] = "Requested line items were successfully deleted"
      end
      redirect_to edit_material_request_path(@material_request) and return
    end

    flash[:notice] = msg_for("Request", @material_request.tracking, @material_request)
    redirect_to edit_material_request_path(@material_request)
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "There were some errors with this material request: #{@material_request.errors.full_messages.join(', ')}"
    render :action => :edit
  end

  def new_line_item
    unless params[:piping_class_detail].blank?
      piping_class_detail = PipingClassDetail.find(params[:piping_class_detail])
      #piping_component = PipingComponent.find(params[:piping_component])

      sizes = extract_sizes(params[:piping_size_1], params[:piping_size_2])
      #comp_details = piping_component.piping_component

      material_description = piping_class_detail.material_description(sizes)
    else
      material_description = "Enter Description"
    end

    if piping_class_detail && piping_class_detail.valve
      notes = piping_class_detail.valve.valve_code
    else
      notes = ""
    end

    @row_count = (params[:row_count] || 1).to_i
    @row_count = 1 if @row_count <= 0

    @items = []
    @row_count.times do
      @items << RequestedLineItem.new(:material_description => material_description, :notes => notes)
    end

    if params[:material_request_id] != "0"
      @material_request = MaterialRequest.find(params[:material_request_id])
      @material_request.items << @items
      @items.each { |i| i.save }
      @material_request.save
    else
      @material_request = MaterialRequest.new
      @items.each_with_index do |item, index|
        item.item_no = params[:item_count].to_i + 1 + index
        item.id = params[:item_count].to_i + 1 + index
      end
    end
end

    def parse_new_line_item
    	if not current_employee.admin?
    		render :text => {:success => false, :errors => "You don't have permission to perform this action"}.to_json and return
    	end
        if request.post? and params[:new_line_item_csv_file]
            @row_count = (params[:row_count] || 1).to_i
            @row_count = 1 if @row_count <= 0
            @line_items_markup = ""
            desc_index = -1
            qty_index = -1
            uom_index = -1
            notes_index = -1
            @index = -1
            begin
                item_no = params[:item_no].to_i
                parsed_rows = CSV.parse(params[:new_line_item_csv_file])

               parsed_rows.each_with_index do |row, index|
                @index = index
                  if(index == 0)
                    row.each_with_index do |header, index|
                      if(header.downcase == "description")
                        desc_index = index
                      end
                      if(header.downcase == "quantity")
                        qty_index = index
                      end
                      if(header.downcase == "uom")
                        uom_index = index
                      end
                      if(header.downcase == "notes")
                        notes_index = index
                      end
                    end
                  else

                    item_no = item_no + 1 + index
                    if(qty_index >= 0)
                      quantity = row[qty_index]
                    else
                      quantity = 0
                    end
                    if(uom_index >= 0)
                      unit_of_measure = row[uom_index]
                    else
                      unit_of_measure = "EA"
                    end
                    if(desc_index >= 0)
                      description = row[desc_index]
                    else
                      description = ""
                    end

                    if(notes_index >= 0)
                      notes = row[notes_index]
                    else
                      notes = ""
                    end

                    item = RequestedLineItem.new(:material_description => description, :notes => notes, :item_no => item_no, :quantity => quantity, :unit_of_measure => unit_of_measure)
                    if(!item.valid?)
                        @json = {:success => false, :errors => "Error on line " + index.to_s + " " + item.errors.full_messages.join(', ')}
                        break
                    end
                    item.id = item_no
                    @material_request = MaterialRequest.new
                    @line_items_markup = @line_items_markup + render_to_string(:partial => "line_item", :locals => { :new_item => true, :item => item})
                    @new_markup = {:markupa => @line_items_markup}
                    @json = {:success => true, :count => @row_count, :markup => @new_markup}
                  end
                end
            rescue StandardError => e

              @json = {:success => false, :errors => "Error on Row " + @index.to_s + " " + e.message}
            end
        end

        render :text => @json.to_json
    end

    def sample_csv
    send_data("quantity,uom,description,notes
3,EA,\"3 Sample Items\",
3,EA,Wrench,5 Inch Wrench
3,EA,Hammer,", :type => "application/csv", :filename => "sample_items.csv")
    end

  #Remove ONE Links to this Order from the requested_line_item
  #if it's the only one on the order, then remove the overall po_link
  def remove_po_link
  	if !current_employee.admin?
  		flash[:error] = "Removing Links to PO's available only to Administrators"
  		redirect_to :action => 'index' and return
  	end
  	ordered_line_item = OrderedLineItem.find(params[:ordered_line_item_id])
  	requested_line_item = RequestedLineItem.find(params[:requested_line_item_id])
  	@modified_line_items = [requested_line_item]
	ordered_line_item.requested_line_item_id = nil
	ordered_line_item.requested_line_item = nil
	ordered_line_item.save!

  	po = Order.find(params[:po_id])

  	#if this was the requested last line item for that order
  	@material_request = requested_line_item.material_request
  	@order_found = false

  	@material_request.items.each do |this_item|
  		if(!this_item.ordered_line_items.empty?)
  			this_item.ordered_line_items.each do |ordered_line_item|
	  			if(ordered_line_item.po_id == po.id)
	  				#we found the order, don't delete the join
	  				@order_found = true
	  			end
  			end
  		end
  	end

  	#if we couldn't find the order
  	if(@order_found == false)
  		#delete the join
  		@material_request.orders.delete(po)
  	end

  end

  #Remove ALL Links to this Order from the material_request
  def remove_po_links
  	if !current_employee.admin?
  		flash[:error] = "Removing Links to PO's available only to Administrators"
  		redirect_to :action => 'index' and return
  	end
  	@material_request = MaterialRequest.find(params[:id])
  	@po = Order.find(params[:po_id])
  	logger.error "material_request has #{@material_request.orders.size} orders."
  	@modified_line_items = []
  	@material_request.orders.each do |order|
  		if(order.id == @po.id)
  			logger.error "material_request has #{@material_request.items.size} items."
  			@material_request.items.each do |requested_line_item|
  				if(!requested_line_item.ordered_line_items.empty?)
  					@modified_line_items << requested_line_item
  					this_list_of_ordered_line_items = requested_line_item.ordered_line_items.find_all_by_po_id(@po.id)
  					if((!this_list_of_ordered_line_items.nil?) && (this_list_of_ordered_line_items.size > 0))
  						this_list_of_ordered_line_items.each do |item|
  							item.requested_line_item_id = nil
  							item.requested_line_item = nil
  							item.save!
  						end
  					end
  				end
  			end

  			@material_request.orders.delete(order)
  		end
  	end
  end

  def remove_line_item
    @item = RequestedLineItem.find_by_id(params[:id]) || nil
    @item.destroy if @item
  end

  def pdf
    tracking = MaterialRequest.find(params[:id]).tracking
    data = `#{ENV['REPORT_USER_COMMAND']} /usr/local/reportman/printreptopdf -paramPSEARCHID=#{params[:id].to_s} -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0 #{RAILS_ROOT}/reports/material_request_horz_linux.rep 2>> #{RAILS_ROOT}/stderr.txt`
    send_data(data, :type => "application/pdf", :filename => "request_#{tracking}.pdf")
  end

  def destroy
    @material_request = MaterialRequest.find(params[:id])
    @material_request.deleted = true
    @material_request.save
    flash[:notice] = "Request has been deleted"
    redirect_to :action => "index"
  end


  def material_request_file
    @material_request_attachment = MaterialRequestAttachment.find(params[:id])
    send_file @material_request_attachment.path
  end

  def del_material_request_file
    @material_request = MaterialRequest.find(params[:id])
      # Pass true to delete if no other Quotes are attached to this quote_attachment.
    attachment = @material_request.material_request_attachments.find_by_id(params[:material_request_attachment_id])
    attachment.delete
    render :nothing => true
  end

  # before_filter :access_key_required
  def quote_file
    @quote_attachment = QuoteAttachment.find(params[:id])
    if(@quote_attachment.nil?)
      render :nothing => true
    else
      send_file @quote_attachment.path
    end
  end

  def del_quote_file
  	@quote = Quote.find(params[:id])
  	# Pass true to delete if no other Quotes are attached to this quote_attachment.
	attachment = @quote.quote_attachments.find_by_id(params[:quote_attachment_id])
	attachment.delete
    render :nothing => true
  end

  # before_filter :access_key_required
  def quote_discuss
    @material_request = MaterialRequest.find(params[:id])
    @quote = Quote.find(:first, :conditions => { :material_request_id => @material_request.id, :vendor_id => @vendor_id })
    author = logged_in? ? current_employee.short_name : "vendor"
    @quote.add_message(params[:message], author)
    render :update do |page|
      page['discussion'].value = h(@quote.discussion)
      page['message'].value = ''
      page['message'].focus
    end
  end

  def quotes
    @material_request = MaterialRequest.find(params[:id])
    @quotes = @material_request.quotes.find(:all, :order => "created_at DESC", :include => "vendor")
  end

  # before_filter :access_key_required
  def quote
    @material_request = MaterialRequest.find(params[:id])
    @quote = Quote.find_or_create(@material_request, @vendor)
    store_location
    # If someone deleted a material request line item that the quote item is
    # tied to, don't show it in the list. Probably should delete the quote_item
    # if the associated requested line item is deleted, too.
    @quote_items = @quote.quote_items.delete_if { |qi| !qi.requested_line_item }
    if request.post?
      params[:quote] ||= {}
      # Moves uploaded_quote_attachments into quote. The file fields aren't named "quote"
      # since the JS code is reused on the email_quote page, and it easier to
      # keep the JS uniform, and modify the Rails side here:
      params[:quote][:uploaded_quote_attachments] = params[:uploaded_quote_attachments]
      @quote.update_attributes!(params[:quote] || {})

      params[:quote_item].each do |quote_item_id, attrs|
        quote_item = @quote.quote_items.find(quote_item_id)
        quote_item.update_attributes!(attrs)
      end

      notified = false
      if params[:notify_requester]
        requester_email = params[:requester_email]
        RequestMailer.send_as_html('quote_change', @quote, requester_email, @vendor.email || "Material Tracker <no-reply@#{ENV['MAIL_DOMAIN']}>") if Rails.env.production?
        notified = true
      elsif params[:notify_vendor]
        vendor_email = params[:vendor_email]
        RequestMailer.send_as_html('quote_change', @quote, vendor_email, current_employee.name_and_email || "Material Tracker <no-reply@#{ENV['MAIL_DOMAIN']}>") if Rails.env.production?
        notified = true
      end

      flash[:notice] = notified ? "Successfully saved this quote and sent a notification email" : "Successfully saved this quote"
      if logged_in?
        redirect_to edit_material_request_path(@material_request)
      else
        redirect_to request.referer
      end
    end
  end

  def update_items_from_request
    @quote = Quote.find(params[:id])
    @quote.update_items_from_request
    @vendor = Vendor.find(@quote.vendor_id)
    @material_request = MaterialRequest.find(@quote.material_request_id)
    redirect_to :action => "quote", :id => @quote.material_request_id, :access_key => @vendor.access_key, :vendor_id => @vendor.id
  end
  	def get_purchaser_group
  		@employee = Employee.find(params[:id])
  		group_id = @employee && @employee.group_id ? @employee.group_id : ''
  		json = {:success => true, :group_id => group_id}
  		render :json => json
 	end

  private

  def find_material_request
    if params[:action] == "create"
      @material_request = current_employee.material_requests.build(:current_employee_id => current_employee.id)
    else
      @material_request = MaterialRequest.find_by_id(params[:id])
    end
  end

  def extract_sizes(first, second)
    if first.blank? && second.blank?
      ""
    elsif first.blank?
      second
    elsif second.blank?
      first
    else
      first + " x " + second
    end
  end


  def check_draft
    if params[:commit] == "Save Draft"
      params[:material_request].merge!(:drafted_by => current_employee.id)
    elsif params[:commit] == "Submit Request to Purchaser"
      params[:material_request].merge!(:drafted_by => nil, :submitted_by => current_employee.id)
    elsif params[:commit] == "Revert to Draft" && params[:material_request][:acknowledged] == "0"
      params[:material_request].merge!(:drafted_by => current_employee.id, :submitted_by => nil)
    end
  end

  def extract_auto_completes
    if params.has_key?(:employee) && params[:employee].has_key?(:list_employee_names)
      params[:material_request][:deliver_to] = params[:employee][:list_employee_names]
    end
    if params.has_key?(:vendor) && params[:vendor].has_key?(:name)
      params[:material_request][:suggested_vendor] = params[:vendor][:name]
    end
    if params.has_key?(:reference_number_type) && params[:reference_number_type].has_key?(:name)
      params[:material_request][:reference_number_type] = params[:reference_number_type][:name]
    end
  end

  def find_suggested_vendor
    @suggested_vendor = nil
    @suggested_vendor = Vendor.find_by_name(@material_request.suggested_vendor) if !@material_request.suggested_vendor.blank?
    if !@suggested_vendor && !@material_request.suggested_vendor.blank?
      suggested = @material_request.suggested_vendor.split(' ').map { |w| '*' + w + '*' }.join(' ')
      suggested = Vendor.search_with_sphinx(suggested)
      if suggested.size == 1
        @suggested_vendor = suggested[0]
      end
    end
  end

  def extract_unit_for_measure
    params[:unit_for_measure] ||= {}
    params[:unit_for_measure][:name] ||= params[:item][params[:item].keys.first][:unit_of_measure]
  end

  def get_list_of_reference_number_types
  	@reference_number_types = ReferenceNumberType.get_list_for_combo
  end

end
