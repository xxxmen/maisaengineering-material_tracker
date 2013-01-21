
class PipingController < SextController
  # show piping_class_details options
  skip_before_filter :is_popv_admin, :only => [
        :index,
        :show,
        :piping_sizes,
        :classes_service,
        :classes_only,
        :piping_components,
        :piping_class_details,
        :piping_class,
        :piping_component,
        :piping_class_detail,
        :classes_only_incl_archived,
        :units_for_measure,
        :all_classes_pdf,
        :details_pdf,
        :valves_pdf
  ]

  RESOURCE = PipingClass

  # Archives the current piping class. Admin only
  def archive
    begin
      if(Employee.current_employee.popv_admin?)
          @record = PipingClass.find(params[:id])
          @record.archive
      end
      @json = {:success => true}
      render :text => @json.to_json
    rescue Exception => ex
      render :json => {:success => false, :errors => ex.message}.to_json
    end
  end

  def unarchive
    begin
      if(Employee.current_employee.popv_admin?)
          @record = PipingClass.find(params[:id])
          @record.unarchive
      end
      @json = {:success => true}
      render :text => @json.to_json
    rescue Exception => ex
      render :json => {:success => false, :errors => ex.message}.to_json
    end
  end

  # Prints a pdf of all piping classes.
  def all_classes_pdf
  	@report_path = PipingClassReport.all_classes_pdf
  	if @report_path.present?
        send_file(@report_path, :type => 'application/pdf', :filename => 'ALL_PIPING_CLASSES.pdf')
    else
		render :text => 'Sorry, the Piping Classes PDF could not be generated for some reason', :status => 500
	end
  end

  # Prints a pdf of all the piping class details associated with the passed
  # in piping class id.
  def details_pdf
  	@report = PipingClassReport.details_pdf(params)
  	if @report.present?
        send_file(@report, :type => 'application/pdf', :filename => 'PIPING_CLASS_DETAILS.pdf')
    else
        flash[:error] = "No Piping Details could be found for this Piping Class"
        redirect_to "/"
    end


#  	piping_class = PipingClass.find(params[:id])

#    print_string = "#{ENV['REPORT_USER_COMMAND']} /usr/local/reportman/printreptopdf -paramPCLASSIDS='#{params[:id]}' #{RAILS_ROOT}/reports/piping_class_details_linux.rep 2>> #{RAILS_ROOT}/log/stderr.txt"

#    logger.error "PDF Command: #{print_string}"
#    data = `#{print_string}`

  end

  def reset_class_order
    begin
      if(Employee.current_employee.popv_admin?)
          @record = PipingClass.find(params[:id])
          @record.reset_details_order
      end
      @json = {:success => true}
      render :text => @json.to_json
    rescue Exception => ex
      render :json => {:success => false, :errors => ex.message}.to_json
    end

  end

  # Prints a pdf of all the valves that are associated with the passed in
  # piping class id.
  def valves_pdf
  	@report = PipingClassReport.valves_pdf(params)
  	report_data = @report.generate

  	if report_data.present?
	  	send_data(report_data, :type => @report.content_type, :filename => @report.title)
    else
	  	render :text => 'There are no valves assigned to this piping class.'
  	end
  end

  # Prints a pdf of all the piping notes.
  def notes_pdf
  	@report = PipingClassReport.notes_pdf
    send_data(@report.generate, :type => @report.content_type, :filename => @report.title)

#    print_string = "#{ENV['REPORT_USER_COMMAND']} /usr/local/reportman/printreptopdf #{RAILS_ROOT}/reports/piping_notes_linux.rep 2>> #{RAILS_ROOT}/log/stderr.txt"

#    logger.error "PDF Command: #{print_string}"
#    data = `#{print_string}`

#    send_data(data, :type => "application/pdf", :filename => "PIPING_NOTES.pdf")
  end

  def clone_class
    @piping_class = PipingClass.find(params[:id])
    @new_piping_class = @piping_class.clone_with_piping_class_details_and_piping_notes(params[:new_class_code])

    @json = { :count => 1, :record => @new_piping_class, :original_class_code => @piping_class.class_code }
    render :json => @json.to_json
  end

  def units_for_measure
  	records = UnitForMeasure.find(:all, :order => "name ASC")
    count =  records.size
    records = Sext.get_data(records, true, params)
    @json = { :count => count, :records => records }
    render :json => @json.to_json
  end

  def piping_sizes
  	records = PipingSize.find(:all, :order => "piping_size ASC")
    count =  records.size
    records = Sext.get_data(records, true, params)
    @json = { :count => count, :records => records }
    render :json => @json.to_json
  end

  def classes_service
    order = params[:sort] + " " + params[:dir] if params[:dir] && params[:sort]

    @records = self.resource.find(:all, :order => order)
    @count =  self.resource.count
    @json = { :count => @count, :records => @records.map { |l| l.class_data} }
    render :json => @json.to_json
  end

  def classes_only
    order = params[:sort] + " " + params[:dir] if params[:dir] && params[:sort]
    @records = self.resource.find(:all, :order => order, :conditions => ['archived = 0'])
    @count =  self.resource.count
    @json = { :count => @count, :records => @records.map { |l| l.class_only} }
    render :json => @json.to_json
  end

  def classes_only_incl_archived
    order = params[:sort] + " " + params[:dir] if params[:dir] && params[:sort]
    @records = self.resource.find(:all, :order => order)
    @count =  self.resource.count
    @json = { :count => @count, :records => @records.map { |l| l.class_only} }
    render :json => @json.to_json
  end

  #these are the components(of the piping_class_details) for a particular piping class
  def piping_components
  	@piping_class = PipingClass.find(params[:piping_class_id])
    @piping_components = @piping_class.piping_components.find(:all, :order => "piping_component").uniq

    @piping_components = @piping_components.map { |l| l.sext_data}
    @json = { :count => @piping_components.size, :records => @piping_components}
    render :json => @json.to_json

  end

  def piping_class_details
  	@piping_component = PipingComponent.find(params[:piping_component_id])
    @piping_class_details = @piping_component.piping_class_details.find(:all, :conditions => { :piping_class_id => params[:piping_class_id] })

    @json = { :count => @piping_class_details.size, :records => @piping_class_details.map { |l|
    valve_code = (l.valve.blank?) ? "" : l.valve.valve_code
    {:id => l.id, :size_and_desc  => l.size_and_description, :size_desc => l.size_desc, :description => l.description, :valve_code => valve_code}

    }}
    render :json => @json.to_json
  end


 	# compare piping classes
  	def compare_piping_classes
  		if params[:ids].present?
  			@details = []
  			class_ids = params[:ids].split(',')

        raw_records = []

        @class_names = ""
  			# give each detail a color
  			class_ids.each_with_index do |class_id, index|
  				@class1 = PipingClass.find(class_id)
          @class_names += "_#{@class1.class_code}"
  				@class1.piping_class_details.each do |detail|
            raw_records << detail
  					detail_in = detail.sext_data
  					detail_in[:line_class] = 'color_' + (index % 10).to_s
  					@details << detail_in
  				end
  			end

  			# Organizes the details by component, size, then class.
  			records = @details.sort do |a,b|
  				a_array = [a[:piping_component].strip, a['size_desc'].strip, a[:piping_class].strip].map {|c| c.present? ? c : ''}

  				b_array = [b[:piping_component].strip, b['size_desc'].strip, b[:piping_class].strip].map {|d| d.present? ? d : ''}

				# [a[:piping_class], a[:piping_component]]<=> [b[:piping_class], b[:piping_component]]}}
  				a_array <=> b_array

 			end

  			@json = {:success => true, :count => @details.size, :records => records}
  		else
  			@json = {:success => false}
    	end
      respond_to do |format|

        format.csv {
          csv_string = FasterCSV.generate do |csv|
            csv << ['Piping Class','Component','Size','Description','Valve','Piping Notes']

            records.each do |record|
              row = []
              ['piping_class','piping_component','size_desc','description','valve','piping_notes'].each do |key|
                v = record[key.to_sym].to_s.strip
                if(v.blank?)
                  row << record[key.to_s].to_s.strip
                else
                  row << v
                end

              end
              csv << row
            end

          end



          send_data(csv_string, :type => "application/csv", :filename => "PIPING_COMPARISON#{@class_names}.csv")

        }
        format.json {
          render :text => @json.to_json
        }
    	end
    end

  # show piping_class_details options
  def piping_class
    @piping_class = PipingClass.find(params[:id])
    @piping_components = @piping_class.piping_components.find(:all, :order => "piping_component").uniq
    if @piping_components.size == 0
      @select_name = '- No Components -'
    else
      @select_name = '- Component -'
    end
  end

  # show piping_class_details options
  def piping_component
    @piping_component = PipingComponent.find(params[:id])
    @piping_class_details = @piping_component.piping_class_details.find(:all, :conditions => { :piping_class_id => params[:piping_class_id] })
    @first_pipe = @piping_class_details.first
    if @first_pipe
      @piping_notes = @first_pipe.piping_notes
      @valve = @first_pipe.valve
    end


  end



  def index(options = {})
    params[:filter] = 'true'
    if(!params[:query].blank?)
    	params[:archived] = ''
    else
    	params[:archived] = params[:archived] || "No"
    end
    #if(!Employee.current_employee.popv_admin?)
    #  params[:archived] = 'No'
    #  params[:archived_field] = 'No'
    #else
        # Default to non-archived, but if archived is specified in the
        # params, use that value.

    #end


    super(options)
  end

  def piping_class_detail
    unless params[:id].blank?
      @piping_class_detail = PipingClassDetail.find(params[:id])
      @piping_notes = @piping_class_detail.piping_notes
      @valve = @piping_class_detail.valve

      @bc9 = (@piping_class_detail.description =~ /BC-9/)
      @bc10 = (@piping_class_detail.description =~ /BC-10/)
      @bc11 = (@piping_class_detail.description =~ /BC-11/)
    end
  end
end

