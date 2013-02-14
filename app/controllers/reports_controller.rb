class ReportsController < ApplicationController
  MODELS_AND_THEIR_RELATIONSHIPS = [
      {
          :model_name => Employee,
          :relationships => [
              { :foreign_key_id => "company_id", :related_model => Company, :column_to_use_in_related_model => "name"},
              { :foreign_key_id => "group_id", :related_model => Group, :column_to_use_in_related_model => "name"},
              { :foreign_key_id => "current_bom_id", :related_model => Bill, :column_to_use_in_related_model => "description"}
          ]
      },
      {
          :model_name => Order,
          :relationships => [
              { :foreign_key_id => "unit_id", :related_model => Unit, :column_to_use_in_related_model => "description"},
              { :foreign_key_id => "vendor_id", :related_model => Vendor, :column_to_use_in_related_model => "name"},
              { :foreign_key_id => "status_id", :related_model => PoStatus, :column_to_use_in_related_model => "status"},
              { :foreign_key_id => "planner_id", :related_model => Employee, :column_to_use_in_related_model => "first_name"},
              { :foreign_key_id => "requested_by_id", :related_model => Employee, :column_to_use_in_related_model => "first_name"},
              { :foreign_key_id => "group_id", :related_model => Group, :column_to_use_in_related_model => "name"}
          ]
      },
      {
          :model_name => MaterialRequest,
          :relationships => [
              { :foreign_key_id => "unit_id", :related_model => Unit, :column_to_use_in_related_model => "description"},
              { :foreign_key_id => "planner_id", :related_model => Employee, :column_to_use_in_related_model => "first_name"},
              { :foreign_key_id => "requested_by_id", :related_model => Employee, :column_to_use_in_related_model => "first_name"},
              { :foreign_key_id => "purchaser_id", :related_model => Employee, :column_to_use_in_related_model => "first_name"},
              { :foreign_key_id => "drafted_by", :related_model => Employee, :column_to_use_in_related_model => "first_name"},
              { :foreign_key_id => "group_id", :related_model => Group, :column_to_use_in_related_model => "name"}
          ]
      },
      {
          :model_name => RequestedLineItem,
          :relationships => [
              { :foreign_key_id => "material_request_id", :related_model => MaterialRequest, :column_to_use_in_related_model => "description"}
          ]
      },
      {
          :model_name => OrderedLineItem,
          :relationships => [
              { :foreign_key_id => "po_id", :related_model => Order,:column_to_use_in_related_model => "po_no"},
              { :foreign_key_id => "requested_line_item_id", :related_model => RequestedLineItem, :column_to_use_in_related_model => "material_description"}
          ]
      }
  ]
  include GruffGrapher

  before_filter :resource_enabled?
  before_filter :admin_required, :only => [:load_fixtures, :csv, :download_database]


  def admin_required
    if(!current_employee.admin?)
      flash[:error] = "You are not authorized to access this page."
      redirect_to main_menu_path and return false
    end
  end

  def index
  end

  def email
    if params[:report] && params[:email]
      report = params[:report]
      email = params[:email]
      if (report[:class].blank? || report[:method].blank?)
        raise "Error: The report information is faulty. Please try again."
      end
      if (email[:to].blank? || email[:subject].blank?)
        raise "Error: The email information is faulty. Please try again."
      end
      RequestMailer.deliver_popv_reports(email, report)
    end

    render :json => { :success => true }
  rescue => e
    error = e.message
    render :json => { :success => false, :message => error }
  end

  def sandbox
    if request.get?
      if(!File.exists?("#{Rails.root}/sandbox.txt"))
        @log = []
      else
        @log = IO.read("#{Rails.root}/sandbox.txt")
        @log = @log.split("\n").uniq.map { |line| line.split("/////") }.reverse[0..30]
      end
    end
    if request.post?
      if params[:report].blank?
        flash[:error] = "Must upload a report!"
        redirect_to :action => "sandbox"
      end

      filename = params[:report].original_filename
      File.open("#{Rails.root}/reports/tmp/#{filename}", "w") do |f|
        f.write(params[:report].read)
      end
      File.open("#{Rails.root}/sandbox.txt", "a+") do |f|
        f.write(params[:filepath] + "/////" + params[:params] + "\n")
      end
      cmd = "/usr/local/reportman/printreptopdf #{params[:params]} #{Rails.root}/reports/tmp/#{filename} 2>> #{Rails.root}/stderr.txt"
      Rails.logger.info cmd
      data = `#{cmd}`


      if data.blank?
        render :text => "<pre>" + IO.read(Rails.root + "/stderr.txt") + "</pre>"
      else
        send_data(data, :type => "application/pdf", :filename => filename + ".pdf")
      end
    end
  end

  def show
    param_string = ""
    report = params[:report]

    if params[:report] == "omni_orders"
      psorter, psearchvalue, psearchfield = params[:reportman][:psorter], params[:reportman][:psearchvalue], params[:reportman][:psearchfield]
      pocc = params[:reportman][:omni_orders][:pocc]
      param_string = "-paramPSORTER=#{psorter} -paramPSEARCHVALUE=\"#{psearchvalue || '_'}\" -paramPSEARCHFIELD=\"#{psearchfield}\" -paramPOCC=#{pocc}"
    elsif params[:report] == "purchase_orders"
      ponos = params[:reportman][:purchase_orders][:ponos]
      ponos = Order.ids_for_pos(ponos).join(',')
      param_string = "-paramPSEARCHID=\"#{ponos}\""
      report = 'print_purchase_order'
    elsif params[:report] == "omni_orders_wo"
      psearchvalue = params[:reportman][:omni_orders_wo][:psearchvalue]
      pocc = params[:reportman][:omni_orders_wo][:pocc]
      param_string = "-paramPSEARCHVALUE=\"#{psearchvalue}\" -paramPOCC=#{pocc}"
    elsif params[:report] == "orders_due"
      if params[:reportman][:orders_due][:timeframe] == 'today'
        report = 'due_today_vendor'
      else
        report = 'due_this_week_vendor'
      end
    elsif params[:report] == "orders_overdue"
      if params[:reportman][:orders_overdue][:sortby] == 'vendor'
        report = 'overdue_vendor'
        pvendorfreshpage = params[:reportman][:orders_overdue][:pvendorfreshpage]
        pvendorfreshpage = pvendorfreshpage.to_s == "1" ? "1" : "0"
        param_string += "-paramPVENDORFRESHPAGE=\"#{pvendorfreshpage}\" "
      elsif params[:reportman][:orders_overdue][:sortby] == 'po'
        report = 'overdue_by_po_num'
      else
        report = 'overdue_eta'
      end
      psearchvendor = params[:reportman][:orders_overdue][:psearchvendor]
      param_string += "-paramPSEARCHVENDOR=\"#{psearchvendor}\""
    elsif params[:report] == "ptm_by_unit"
      punit, pyear, pstatus = params[:reportman][:punit], params[:reportman][:pyear], params[:reportman][:pstatus]
      param_string = "-paramPUNIT=\"#{punit}\" -paramPYEAR=#{pyear} -paramPSTATUS=#{pstatus} -paramPSUBTOTAL=0"
    elsif params[:report] == "received_by_date"
      pstartdate, penddate = params[:reportman][:pstartdate], params[:reportman][:penddate]
      param_string = "-paramPSTARTDATE=#{pstartdate.to_date.strftime('%m/%d/%y')} -paramPENDDATE=#{penddate.to_date.strftime('%m/%d/%y')}"
    elsif params[:report] == "work_orders"
      psubtotal, ptotal, pwono = "0", "0", params[:reportman][:pwono]
      pyear = params[:reportman][:work_orders][:pyear]
      param_string = "-paramPSUBTOTAL=0 -paramPTOTAL=0 -paramPWONO=\"#{pwono}\" -paramPYEAR=\"#{pyear}\""
    elsif params[:report] == "material_request"
      psearchid = params[:reportman][:mrids]
      param_string = "-paramPSEARCHID=\"#{psearchid}\" -paramPINSIDETRACKER=0 -paramPTRACKINGCOUNTER=0"
      if params[:direction] == "landscape"
        report = "material_request_horz"
      else
        report = "material_request_vert"
      end
    elsif params[:report] == "expediting_by_vendor"
      psearchid = params[:reportman][:vendor_name]
      param_string = "-paramPSEARCHID=\"#{psearchid}\""
    elsif params[:report] == "inventory_reorder_items_by_vendor"
      psearchid = params[:inventory_reorder_items_by_vendor][:vendor_name]
      param_string = "-paramPSEARCHID=\"#{psearchid}\""
    elsif params[:report] == "inventory_items"
      psearchvendor, psearchitem = params[:reportman][:inventory_items][:psearchvendor], params[:reportman][:inventory_items][:psearchitem]
      param_string = "-paramPSEARCHVENDOR=\"#{psearchvendor}\" -paramPSEARCHITEM=\"#{psearchitem}\""
      report = params[:reportman][:inventory_items][:orderby] == 'stockno' ? 'inventory_items_by_stockno' : 'inventory_items_by_vendor'
    elsif params[:report] == "cost_wo_vendor"
      pvendor, pwono = params[:reportman][:cost_wo_vendor][:pvendor], params[:reportman][:cost_wo_vendor][:pwono]
      param_string = "-paramPVENDOR=\"#{pvendor}\" -paramPWONO=\"#{pwono}\""
    elsif params[:report] == "unit_stats"
      us_params = params[:reportman][:unit_stats]
      punit, pstartdate, penddate = us_params[:punit], us_params[:pstartdate], us_params[:penddate]
      param_string = "-paramPUNIT=\"#{punit}\" -paramPSTARTDATE=\"#{pstartdate}\" -paramPENDDATE=\"#{penddate}\""
    elsif params[:report] == "unit_stats_week"
      punit = params[:reportman][:unit_stats_week][:punit]
      param_string = "-paramPUNIT=\"#{punit}\""
    elsif params[:report] == "unit_stats_2week"
      punit = params[:reportman][:unit_stats_2week][:punit]
      param_string = "-paramPUNIT=\"#{punit}\""
    elsif params[:report] == "unit_stats_30day"
      punit = params[:reportman][:unit_stats_30day][:punit]
      param_string = "-paramPUNIT=\"#{punit}\""
    elsif params[:report] == "unit_stats_month"
      us_params = params[:reportman][:unit_stats_month]
      punit, pmonth, pyear = us_params[:punit], us_params[:pmonth], us_params[:pyear]
      pstartdate = "#{pmonth}/1/#{pyear}"
      param_string = "-paramPUNIT=\"#{punit}\" -paramPSTARTDATE=\"#{pstartdate}\""
    elsif params[:report] =~ /graph/ # If value retured has graph anywhere in it, redirect.
      redirect_to :action => "graphing", :report => params[:report]
      return
    end

    cmd = "#{ENV['REPORT_USER_COMMAND']} /usr/local/reportman/printreptopdf #{param_string} #{Rails.root}/reports/#{report}_linux.rep 2>> #{Rails.root}/stderr.txt"
    Rails.logger.info cmd
    data = `#{cmd}`
    filename = report.include?("omni_orders") ? "orders" : report
    if data.blank?
      render :action => :no_data
    else
      send_data(data, :type => "application/pdf", :filename => "#{filename}.pdf")
      return
    end
  end

  # Generates beautiful graphs!
  def graphing
    #graph_gruff
    #send_data @image, :filename => "jobs.png", :type => "image/png", :disposition => "inline"
    generate_gruff_pdf
    send_data(@pdf, :type => "application/pdf", :filename => "bp.pdf", :disposition => "inline")
  end

  def csv
  end

  def import_export

  end

  def export_to_csv
    model_to_export = params[:export_model].constantize
    render :csv => model_to_export.scoped, :filename => "#{params[:export_model]}"
  end

  def import_to_csv
    if not current_employee.admin?
      render :text => {:success => false, :errors => "You don't have permission to perform this action"}.to_json and return
    end
    if request.post? and params[:import_file]
      model_to_import = params[:import_model].constantize
      begin
        parsed_rows = FasterCSV.parse(params[:import_file])
        instances_of_model_for_each_row = []
        indexes_of_columns_in_uploaded_file = {}
        column_names = []
        parsed_rows[0].each_with_index do |column_name, index|
          indexes_of_columns_in_uploaded_file[column_name] = index and column_names.push column_name if column_name != "id" and column_name != "delta"
        end

        table_rows = []
        is_there_a_relationship_to_be_created = false

        parsed_rows.each_with_index do |row, index|
          if index != 0 # First row is going to be headers only
            table_row = {}
            indexes_of_columns_in_uploaded_file.each do |column_name, index_in_row|
              table_row[column_name] = {}
              table_row[column_name][:cell_value]= row[index_in_row]
              table_row[column_name][:cell_name] = "#{column_name}_#{index}_#{index_in_row}"
              table_row[column_name][:cell_color] = "none"

              if !row[index_in_row].nil? and !row[index_in_row].empty?
                MODELS_AND_THEIR_RELATIONSHIPS.each do |model_with_association|
                  if model_to_import == model_with_association[:model_name]
                    model_with_association[:relationships].each do |relationship|
                      model_to_import.column_names.each do |model_column_name|
                        if model_column_name == relationship[:foreign_key_id]
                          transformed_column_name = ""
                          if model_column_name.index('id').nil?
                            transformed_column_name = model_column_name + ('_' + relationship[:column_to_use_in_related_model])
                          else
                            transformed_column_name = model_column_name.gsub('_id','_' + relationship[:column_to_use_in_related_model])
                          end

                          if transformed_column_name == column_name
                            if eval("#{relationship[:related_model]}.find_by_#{relationship[:column_to_use_in_related_model]}(\"#{row[index_in_row]}\")").nil?
                              table_row[column_name][:cell_color] = "green"
                              is_there_a_relationship_to_be_created = true
                            else
                              table_row[column_name][:cell_color] = "blue"
                              is_there_a_relationship_to_be_created = true
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end

            end
            table_rows.push table_row
          end
        end

        render :text => {:success => true, :markup => render_to_string(:partial => "new_import_preview", :locals => {:model_to_import => params[:import_model], :column_names => column_names, :table_rows => table_rows, :is_there_a_relationship_to_be_created => is_there_a_relationship_to_be_created})}.to_json
      rescue
        render :text => {:success => false, :errors => "Kindly upload a proper CSV file for #{params[:import_model]}"}.to_json
      end

    else
      render :text => {:success => false, :errors => "Kindly upload a CSV file"}.to_json
    end
  end

  def submit_import_preview
    return if not request.post?
    number_of_rows = params[:number_of_rows].to_i
    model_to_import = params[:import_model].constantize
    column_names = params[:column_names].split(',')
    number_of_records_created = 0

    begin
      index = 0
      while index < number_of_rows do
        index = index + 1
        if params["row_#{index}"] # Check if the row was not removed
          attributes = {}
          column_names.each_with_index do |column_name, column_count|
            attributes[column_name] = params["#{column_name}_#{index}_#{column_count + 1}"] if model_to_import.column_names.include?(column_name)
            MODELS_AND_THEIR_RELATIONSHIPS.each do |model_with_association|
              if model_to_import == model_with_association[:model_name]
                model_with_association[:relationships].each do |relationship|
                  model_to_import.column_names.each do |model_column_name|
                    if model_column_name == relationship[:foreign_key_id]
                      transformed_column_name = ""
                      if model_column_name.index('id').nil?
                        transformed_column_name = model_column_name + ('_' + relationship[:column_to_use_in_related_model])
                      else
                        transformed_column_name = model_column_name.gsub('_id','_' + relationship[:column_to_use_in_related_model])
                      end

                      if transformed_column_name == column_name
                        actual_param_value = params["#{transformed_column_name}_#{index}_#{column_count + 1}"]
                        if !actual_param_value.nil? and !actual_param_value.empty?
                          instance_in_db = eval("#{relationship[:related_model]}.find_by_#{relationship[:column_to_use_in_related_model]}(\"#{actual_param_value}\")")
                          if instance_in_db.nil?
                            new_instance = eval("#{relationship[:related_model]}.create!(:#{relationship[:column_to_use_in_related_model]} => \"#{actual_param_value}\")")
                            attributes[model_column_name] = new_instance.id
                          else
                            attributes[model_column_name] = instance_in_db.id
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          model_to_import.create!(attributes)
          number_of_records_created = number_of_records_created + 1
        end
      end
      flash[:notice] = "#{number_of_records_created} item(s) added to #{model_to_import}"
    rescue => error
      flash.now[:error] = "Could not create because : #{error}"
    end

    render :action => "import_export"
  end

  def load_fixtures
    [Company, Employee, InventoryItem, LogEdit, MaterialRequest, Order, OrderedLineItem, PoStatus, RequestedLineItem, Unit, Vendor].each do |m|
      path = "#{Rails.root}/db/#{m.table_name}.csv"
      if File.exists?(path)
        m.load_from_file
        File.delete(path)
      end
    end

    ActiveRecord::Base.connection.execute("TRUNCATE TABLE log_edits")
    flash[:message] = "New database has been loaded"
    redirect_to "/"
  end

  def rebuild_index
    [Company, Employee, MaterialRequest, Order, Unit, Vendor].each do |m|
      m.rebuild_index
    end

    flash[:notice] = "Index was rebuilt at " + current_time
    redirect_to "/"
  end

  def download_database
    [Company, Employee,InventoryItem, LogEdit, MaterialRequest, Order, OrderedLineItem, PoStatus, RequestedLineItem, Unit, Vendor].each do |m|
      m.dump_to_file   # dumps to Rails.root/db/table_name.csv
    end
    `zip #{Rails.root}/tmp/csv.zip #{Rails.root}/db/*.csv`
    `rm #{Rails.root}/db/*.csv`

    send_file "#{Rails.root}/tmp/csv.zip", :type => "application/zip", :disposition => "attachment", :filename => "csv.zip"
  end

  def replace_foreign_key_ids_in_csv(model_to_export, csv_file_data)
    MODELS_AND_THEIR_RELATIONSHIPS.each do |model_with_association|
      if model_to_export == model_with_association[:model_name]
        parsed_rows = FasterCSV.parse(csv_file_data)
        model_with_association[:relationships].each do |relationship|
          foreign_key_index_in_row_for_relationship = nil
          parsed_rows[0].each_with_index do |column_name, index|
            foreign_key_index_in_row_for_relationship = index if column_name == relationship[:foreign_key_id]
          end
          parsed_rows.each_with_index do |parsed_row, index|
            if index != 0 and !parsed_row[foreign_key_index_in_row_for_relationship].nil? and !parsed_row[foreign_key_index_in_row_for_relationship].empty?
              parsed_row[foreign_key_index_in_row_for_relationship] = eval("#{relationship[:related_model]}.find_by_id(#{parsed_row[foreign_key_index_in_row_for_relationship]}).#{relationship[:column_to_use_in_related_model]}")
            end
          end
          parsed_rows[0].each do |column_name|
            if column_name == relationship[:foreign_key_id]
              column_name << ('_' + relationship[:column_to_use_in_related_model]) if column_name.index('id').nil?
              column_name.gsub!('_id','_' + relationship[:column_to_use_in_related_model])
            end
          end
        end

        csv_file_data = FasterCSV.generate do |csv|
          parsed_rows.each{|row| csv << row}
        end
      end
    end

    csv_file_data
  end

end
