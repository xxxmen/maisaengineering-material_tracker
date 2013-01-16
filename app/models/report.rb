# By: Adam Grant
# Date: 2009-08-03
#
# Wrapper class for generating ReportMan reports.
# Basic Usage:
#	@report = Report.new
#	@report.report_name = "/home/my_app/public/report.rep"
#   @report.generate
#
# To view the shell output without actually running the command, call #get_command.
#

class Report

  ##############################################################################
  # CONSTANTS

	COMMAND_PREFIX = ''
	COMMAND = '/usr/local/reportman/printreptopdf'
	COMMAND_WIN = "\"c:\\Program Files\\Report Manager\\printreptopdf.exe\""
	COMMAND_CYGWIN = "\"/cygdrive/c/Program\ Files/Report\ Manager/printreptopdf.exe\""
	CONTENT_TYPE = 'application/pdf'
	ERROR_OUTPUT = "2>> #{RAILS_ROOT}/log/stderr.txt"


  ##############################################################################
  # ATTRIBUTES

	attr_accessor :command_prefix, :command, :options, :report_name, :output, :title, :content_type


  ##############################################################################
  # CLASS METHODS

	def self.interpret_report(report_class, report_method, options)
		report_class = report_class.classify.to_sym
		klass = Module.const_get(report_class)

  		if klass && [PipingClassReport, BillsReport, ValvesReport].include?(klass)
  			klass.send(report_method.to_sym, options)
 		end
	end

  ##############################################################################
  # INSTANCE METHODS

	# Execute the report and return the result.
	def generate
		command = self.get_command
		`#{command}`
	end


	# Builds the shell command up.
	def get_command(show_in_log = false)
		command_array = [self.command_prefix, self.command, self.options, self.report_name, self.output]
		cmd = command_array.select {|c| c.present? }.join(' ')
		RAILS_DEFAULT_LOGGER.info cmd
		puts cmd #if (RAILS_ENV == 'development' || show_in_log)
		cmd
	end


	def command_prefix
		@command_prefix ||= COMMAND_PREFIX
	end


	# Returns the ReportMan's printreptopdf command, depending on the OS.
	def command
		@command ||= case RUBY_PLATFORM
			when /mswin32/ then	COMMAND_WIN
			when /cygwin/ then COMMAND_CYGWIN
			else COMMAND
		end
	end


	def content_type
		@content_type ||= CONTENT_TYPE
	end


	def output
		@output ||= ERROR_OUTPUT
	end
end

class PipingClassReport < Report
  ##############################################################################
  # CLASS METHODS
    def self.all_classes_pdf
		class_id = '0'

		report = self.new
		report.options = "-paramPCLASSIDS='#{class_id}'"
		report.report_name = "#{RAILS_ROOT}/reports/piping_class_details_no_notes_linux.rep"
		report.title = "ALL_PIPING_CLASSES.pdf"

		# Creates a new Tempfile and writes the generated report to it.
		report_file = Tempfile.new(report.title)
		report_file.write report.generate
		report_file.close

		report_file.path
   	end

	def self.details_pdf(params)
		class_id = params["id"]
		piping_class = PipingClass.find(class_id)
		class_code = piping_class.class_code

		report = self.new
		report.options = "-paramPCLASSIDS='#{class_id}'"
		report.report_name = "#{RAILS_ROOT}/reports/piping_class_details_no_notes_linux.rep"
		report.title = "PIPING_CLASS_DETAILS_#{class_code}.pdf"

		class_report = report.generate
	    piping_classes_pdf = Tempfile.new("piping_classes_pdf")
	    piping_classes_pdf.write class_report
	    piping_classes_pdf.close

		report = self.new
		report.options = "-paramPCLASSIDS='#{class_id}'"
		report.report_name = "#{RAILS_ROOT}/reports/piping_class_details_piping_notes.rep"
		report.title = "PIPING_CLASS_NOTES.pdf"

		notes_report = report.generate

		piping_notes_pdf = Tempfile.new("piping_classes_pdf")
		piping_notes_pdf.write notes_report
		piping_notes_pdf.close

		new_pdf = "#{RAILS_ROOT}/tmp/tmp_report.pdf"

		if class_report.size > 0 && notes_report.size > 0
		    # Concatenates the two PDF's together
		    `gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=#{new_pdf} #{piping_classes_pdf.path} #{piping_notes_pdf.path}`
		elsif class_report.size > 0
		    new_pdf = piping_classes_pdf.path
		else
		    new_pdf = ""
		end

		return new_pdf
	end


	def self.valves_pdf(params)
		class_id = params["id"]
		report = self.new
		piping_class = PipingClass.find(class_id)
		class_code = piping_class.class_code

		report.options = "-paramPCLASSID='#{class_id}'"
		report.report_name = "#{RAILS_ROOT}/reports/valve_sheets_for_piping_class_linux.rep"
		report.title = "VALVE_SHEETS_FOR_PIPING_CLASS_#{class_code}.pdf"
		report
	end


  	def self.notes_pdf
		report = self.new
		report.report_name = "#{RAILS_ROOT}/reports/piping_notes_linux.rep"
		report.title = "PIPING_NOTES.pdf"
		report
	end
end


class BillsReport < Report

  ##############################################################################
  # CLASS METHODS

	def self.request_for_quote_pdf(params)
		report = self.new
	  	bill = Bill.find(params["id"])
	  	tracking = bill.id

		report.options = "-paramPSEARCHID=#{tracking} -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0"
		report.title = "BOM_#{tracking}-Request_For_Quote.pdf"

		case RUBY_PLATFORM
			when /mswin32/
				report.report_name = "\"#{RAILS_ROOT}\\reports\\popv_bom_rfq_vert_windows.rep\""
				report.output = nil
			when /cygwin/
				report.report_name = "\"#{RAILS_ROOT}\\reports\\popv_bom_rfq_vert_windows.rep\""
			else # *nix
				report.report_name = "#{RAILS_ROOT}/reports/popv_bom_rfq_vert_linux.rep"
		end

		report
  	end


  	def self.pdf(params)
		report = self.new

	  	bill = Bill.find(params["id"])
	  	tracking = bill.id

	  	report.options = "-paramPSEARCHID=#{tracking} -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0"
		report.title = "BOM_#{tracking}.pdf"

		case RUBY_PLATFORM
			when /mswin32/
				report.report_name = "\"#{RAILS_ROOT}\\reports\\popv_bom_vert_windows.rep\""
				report.output = nil
			when /cygwin/
				report.report_name = "\"#{RAILS_ROOT}\\reports\\popv_bom_vert_windows.rep\""
			else
				report.report_name = "#{RAILS_ROOT}/reports/popv_bom_vert_linux.rep"
		end

		report
  	end
end

class ValvesReport < Report

  ##############################################################################
  # CLASS METHODS

	def self.all_pdf(params)
		report = self.new

		report.options = "-paramPVALVEIDS='0'"
		report.report_name = "#{RAILS_ROOT}/reports/valve_sheet_linux.rep"
		report.title = "ALL_VALVES_SHEET.pdf"

		report
#		report_name = "#{RAILS_ROOT}/reports/valve_sheet_linux.rep"

#		@valves = Valve.find(:all, :order => 'valve_code ASC')
#
#		final_pdf = Tempfile.new("all_valves_pdf")
#
#		valve_pdfs = []

#		@valves.each_with_index do |valve, index|
#			report = self.new
#			report.options = "-paramPVALVEIDS='#{valve.id}'"
#			report.report_name = report_name
#
#			temp_report = report.generate
#
#		    temp_file = Tempfile.new("valves_pdf")
#		    temp_file.write(temp_report)
#		    temp_file.close
#
#		    valve_pdfs << temp_file
#		end
#
#	   	command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=#{final_pdf.path}"
#
#		   #logger.info "temporary output file: #{output_order.path}"
#		valve_pdfs.each do |pdf|
#		   	command += " #{pdf.path}"
#		end
#
#		command += " >& /dev/null"
#
#		RAILS_DEFAULT_LOGGER.info "Command to output: #{command}\r\n"
#
#		#execute the command
#		RAILS_DEFAULT_LOGGER.info `#{command}`
#
#		valve_pdfs.each do |pdf_to_delete|
#		    `rm #{pdf_to_delete.path}`
#		end
#
#		return final_pdf.path

#		report
#
#
#		#this is an array of arrays
#                        _ids_array = []
#
#                        #Break the ids up into groups of 25
#        @ordered_items.each_with_index do |item, index|
#            if((index % 25) == 0)
#                arrays_index = arrays_index + 1
#                _ids_array[arrays_index] = []
#            end
#
#            # Check and see if the certified belongs to this customer, if not it raises an exception
#            result = current_user.check_customers_in_ordered_item(item)
#            if result != true
#                    flash[:error] = result
#                    raise "CUSTOMER DOESN'T MATCH"
#            else
#                    _ids_array[arrays_index] << item.id
#            end
#            endoutput_order = Tempfile.new("output_sales_order")
#			output_order.close

#		   	partial_orders = []
#
#		  	_ids_array.each_with_index do |partial_order, index|

#			    data = generate_pdf_from_ids(partial_order.join(','), _sales_order_id)
#			    parial_order = Tempfile.new("partial_sales_order")
#			    parial_order.write data
#			    parial_order.close
#			    partial_orders << parial_order
#
#		   end
#		   command = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=#{output_order.path}"
#
#		   #logger.info "temporary output file: #{output_order.path}"
#		   partial_orders.each do |partial|
#		    	command += " #{partial.path}"
#		   end
#		   command += " >& /dev/null"
#
#		   logger.info "Command to output: #{command}\r\n"
#
#		   #execute the command
#		   logger.info `#{command}`
#
#		   partial_orders.each do |partial|
#		    `rm #{partial.path}`
#		   end
#
#		   send_file(output_order.path, :type => "application/pdf", :filename => "Certified MTRs for Sales Order ##{@sales_order.newmans_so_number}.pdf")
#
	end



  	def self.pdf(params)
		report = self.new

	  	valve = Valve.find(params["id"])

		report.options = "-paramPVALVEIDS='#{params["id"]}'"
		report.report_name = "#{RAILS_ROOT}/reports/valve_sheet_linux.rep"
		report.title = "VALVE_SHEET_#{valve.valve_code}.pdf"

		report
	end

	def self.comparison_pdf(params)
		report = self.new
		@valve_codes = ''

		#get both valves and their codes for the PDF name
		valve = Valve.find(params["valve_1_id"])
		@valve_codes += valve.valve_code
		valve = Valve.find(params["valve_2_id"])
		@valve_codes += "_" + valve.valve_code



		report.options = "-paramPVALVEIDS='#{params["valve_1_id"]},#{params["valve_2_id"]}'"
		report.report_name = "#{RAILS_ROOT}/reports/valve_sheet_linux.rep"
		report.title = "VALVE_COMPARISON_#{@valve_codes}.pdf"

		report
	end
end
