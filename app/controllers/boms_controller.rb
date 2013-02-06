class BomsController < SextController
	RESOURCE = Bill

  	before_filter :is_popv_admin, :except => [:index, :show, :current, :set_current, :pdf, :create]

  	def index
    	if params[:filter2]
        	if params[:filter2] == 'drafts'
            	params['status'] = 'Draft'
         	elsif params[:filter2] == 'mine'
             	params['created_by'] = Employee.current_employee.id
         	elsif params[:filter2] == 'all'
             	params['status'] = ''
             	params['created_by'] = ""
         	elsif params[:filter2] == 'current'
         		params['id'] = Employee.current_employee.current_bom_id
         	end
         	params[:filter] = 'true'
     	end

     	super()
   	end


  	def is_popv_admin
    	#popv admin can do anything
    	if current_employee.popv_admin?
        	return true
    	end
    	if params[:id]
        	bill = Bill.find(params[:id])
        	#we're allowed to edit/Delete/update our own bills only
        	if(bill.employee.id == current_employee.id)
            	return true
        	else
            	return false
        	end
    	else
        	return false
    	end
  	end


	def create_material_request
		@record = Bill.find(params[:id])
    	@record, message = @record.create_material_request

       	@json = {:success => true, :record => @record.sext_data, :message => message}
    	render :text => @json.to_json and return
	rescue ActiveRecord::RecordInvalid
		# TODO: Revise this. I don't think this works well at all.
		# Ex: If we caught this exception, message probably doesn't exist.
    	@json = {:success => false, :errors => {}, :message => message}
    	@record.errors.each { |key, val| @json[:errors][key] = val }
    	render :text => @json.to_json and return

	end

	# Creates a clean copy of the Bill with params[:id] and all it's line items.
  	def copy
    	@bill = Bill.find(params[:id])
    	new_bill = @bill.create_new_copy

   	    render :json => {:success => true, :record => new_bill.sext_data}.to_json
  	end

	# Supersedes the Bill with params[:id] by creating a new copy of the Bill
	# and all it's line items.
  	def supersede
    	@bill = Bill.find(params[:id])

    	new_bill = @bill.supersede

    	# This is what happens in regular update
    	if new_bill.save
    	    render :json => {:success => true, :record => new_bill.sext_data}.to_json
    	else
    	    render :json => {:success => false, :errors => new_bill.errors}.to_json
    	end
  	end

  	def pdf
  		@report = BillsReport.pdf(params)
  		send_data(@report.generate, :type => @report.content_type, :filename => @report.title)

#	  	bill = Bill.find(params[:id])
#	  	tracking = bill.id
#
#	    if RUBY_PLATFORM =~ /mswin32/
#	        print_string = "\"c:\\Program Files\\Report Manager\\printreptopdf.exe\" -paramPSEARCHID=#{tracking} -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0 \"#{Rails.root}\\reports\\popv_bom_vert_windows.rep\" "
#	    elsif RUBY_PLATFORM =~ /cygwin/
#	        print_string = "\"/cygdrive/c/Program\ Files/Report\ Manager/printreptopdf.exe\" -paramPSEARCHID=#{tracking} -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0 \"#{Rails.root}\\reports\\popv_bom_vert_windows.rep\" 2>> #{Rails.root}\\stderr.txt"
#	    else
#	        print_string = "#{ENV['REPORT_USER_COMMAND']}  /usr/local/reportman/printreptopdf -paramPSEARCHID=#{tracking} -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0 #{Rails.root}/reports/popv_bom_vert_linux.rep"
#	    end
#
#	    logger.error "PDF Command: #{print_string}"
#
#	    data = `#{print_string}`
#
#	    send_data(data, :type => "application/pdf", :filename => "BOM_#{bill.tracking}.pdf")
  	end

  	def request_for_quote_pdf
  		@report = BillsReport.request_for_quote_pdf(params)
  		send_data(@report.generate, :type => @report.content_type, :filename => @report.title)

#	  	bill = Bill.find(params[:id])
#	  	tracking = bill.id

#	    if RUBY_PLATFORM =~ /mswin32/
#	        print_string = "\"c:\\Program Files\\Report Manager\\printreptopdf.exe\" -paramPSEARCHID=#{tracking} -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0 \"#{Rails.root}\\reports\\popv_bom_rfq_vert_windows.rep\" "
#	    elsif RUBY_PLATFORM =~ /cygwin/
#	        print_string = "\"/cygdrive/c/Program\ Files/Report\ Manager/printreptopdf.exe\" -paramPSEARCHID=#{tracking} -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0 \"#{Rails.root}\\reports\\popv_bom_rfq_vert_windows.rep\" 2>> #{Rails.root}\\stderr.txt"
#	    else
#	        print_string = "#{ENV['REPORT_USER_COMMAND']}  /usr/local/reportman/printreptopdf -paramPSEARCHID=#{tracking} -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0 #{Rails.root}/reports/popv_bom_rfq_vert_linux.rep"
#	    end

#	    logger.error "PDF Command: #{print_string}"

#	    data = `#{print_string}`
#
#	    send_data(data, :type => "application/pdf", :filename => "BOM_#{bill.tracking}-Request_For_Quote.pdf")
  	end


	def excel
    @bill = Bill.find(params[:bill_id])
    if @bill
      number_of_bill_items_per_page = 10
      @all_bill_items = Bill.find_items_for_xml_export(params[:bill_id], number_of_bill_items_per_page)
      @page_count = @all_bill_items.size
      @class_code = @all_bill_items.blank? ? "" : @all_bill_items[0][0].class_code
      if(current_employee.bom_xls_file == "turnaround_planning_department_work_package_template")
        self.headers['Content-Disposition'] = "attachment; filename=Turnaround_Planning_Department_Work_Package_Template_BOM_#{@bill.tracking}.xml"
        render :layout => false, :action => 'turnaround_planning_department_work_package_template', :content_type => 'application/vnd.ms-excel'
      else
        self.headers['Content-Disposition'] = "attachment; filename=Form_58001_BOM_#{@bill.tracking}.xml"
        render :layout => false, :action => 'form_58001', :content_type => 'application/vnd.ms-excel'
      end
    else
     redirect_to :back
    end
	end

  	def csv
    	data = Bill.find_items_for_export(params[:id])
    	bill = Bill.find(params[:id])

    	our_columns = ['requester_first_name', 'requester_last_name', 'requester_telephone', 'unit_description', 'unit_no', 'work_order', 'bill_id', 'description', 'required_on', 'tracking', 'process', 'mes', 'suggested_vendor', 'delivery_type', 'special_instructions', 'status', 'item_no', 'quantity', 'unit_of_measure', 'line_description', 'notes', 'class_code', 'requestor_department', 'deliver_to', 'attention', 'will_call', 'will_call_extension_or_radio','stage', bill.reference_number_1_type, bill.reference_number_2_type, bill.reference_number_3_type]


    	require 'csv'

  		report = StringIO.new

  		CSV::Writer.generate(report, ',', "\r\n") do |title|
        	title << our_columns

	      	data.each do |r|
	      	  	this_data = []
	      	  	our_columns.each do |column|

	      	  		# Special considerations for reference numbers, since their "type" can change per record.
      	  			if column == bill.reference_number_1_type
      	  				if r['reference_1'].present?
		      	      		sData = r['reference_1'].to_s.gsub("\r", "").gsub("\n", "")
		      	      		this_data << sData
		    	      	else
		    	        	this_data << ""
	    	        	end

      	  			elsif column == bill.reference_number_2_type
      	  				if r['reference_2'].present?
		      	      		sData = r['reference_2'].to_s.gsub("\r", "").gsub("\n", "")
		      	      		this_data << sData
		    	      	else
		    	        	this_data << ""
	    	        	end
      	  			elsif column == bill.reference_number_2_type
      	  				if r['reference_3'].present?
		      	      		sData = r['reference_3'].to_s.gsub("\r", "").gsub("\n", "")
		      	      		this_data << sData
		    	      	else
		    	        	this_data << ""
	    	        	end

    	        	else	# The rest of the columns:
		      	    	if !r[column].blank?
		      	      		sData = r[column].to_s.gsub("\r", "").gsub("\n", "")
		      	      		this_data << sData
		    	      	else
		    	        	this_data << ""
		    	      	end
	    	      	end
	      		end

	      	  	title << this_data
	    	end
	    end

	  	report.rewind

   		send_data(report.read,
   			:type=>'text/csv;charset=iso-8859-1;header=present',
			:filename=>"BOM_#{data[0].tracking}.csv",
			:disposition =>'attachment',
			:encoding => 'utf8'
		)
  	end

  	def current
	    if Employee.current_employee.current_bom_id
	        current_id = Employee.current_employee.current_bom_id
	    else
	        current_bill = Bill.find(:first,
	        	:conditions => "((status = 'Draft') OR (status IS NULL)) AND (created_by = #{Employee.current_employee.id})",
	        	:order => 'updated_at DESC'
	        )

	        if !current_bill.nil?
	            Employee.current_employee.current_bom = current_bill
	        end
	    end

	    if Employee.current_employee.current_bom
	        render :json => {:current_bom_id => Employee.current_employee.current_bom_id}.to_json
	    else
	        render :json => {:current_bom_id => false}.to_json
	    end
	    Employee.current_employee.save
  	end

  	def set_current
    	Employee.current_employee.current_bom_id = params[:id]
    	if Bill.find_by_id(params[:id])
        	render :json => {:success => true}.to_json
    	else
        	render :json => {:success => false}.to_json
    	end
    	Employee.current_employee.save
  	end
end
