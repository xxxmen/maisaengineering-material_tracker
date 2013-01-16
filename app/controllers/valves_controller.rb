class ValvesController < SextController
  RESOURCE = Valve
  DEFAULT_LIMIT = 200

  # Only admins are allowed to archive valves.
  before_filter :is_popv_admin, :only => [:archive]

  def index
    params[:additional_conditions] = ['',[]]
    if(!params[:valve_components].blank?)
      valve_components = ActiveSupport::JSON.decode(params[:valve_components])
    else
      valve_components = []
    end

    valve_components.each do |comp|
      if(!comp['component_text'].blank?)
        #vc = ValveComponent.find(comp['valve_component_id'])

        arr_search = ["#{comp['valve_component_id']}", "%#{comp['component_text']}%"]
        str_search = "valves.id IN (SELECT vvc1.valve_id FROM valves_valve_components vvc1 LEFT OUTER JOIN valve_components vc1 on vvc1.valve_component_id = vc1.id WHERE "
        str_search = str_search + " vc1.id = ? AND vvc1.component_text LIKE ?)"

        if(!params[:additional_conditions][0].blank?)
          params[:additional_conditions][0] += " AND "
        end
        params[:additional_conditions][0] += str_search
        params[:additional_conditions][1] += arr_search
      end
    end

    # We really want to always use filtering.
    params[:filter] = 'true'

    # filter2 parameter is used by the ExtJS code for grabbing only a
    # specified id, so that we can show only one valve in the grid.
    # In this case we don't care about whether it is archived or not.
    if params[:filter2]
        # Reassign the value to the id param. Then delete filter2 so it
        # doesn't try and search for it as a SQL table field.
        params[:id] = params[:filter2]
        params.delete(:filter2)
    else
	    if(!Employee.current_employee.popv_admin?)
            params[:archived] = "No"
        else
            # Default to non-archived, but if archived is specified in the
            # params, use that value.
            params[:archived] = params[:archived] || "No"
        end
    end

    # Call the sext_controller's index method.
    super

  end

  # Archives the passed in valve. Only allowed for admins.
  def archive
    if(Employee.current_employee.popv_admin?)
        @record = Valve.find(params[:id])
        @record.archive
    end
    @json = {:success => true}
    render :text => @json.to_json
  end

  def unarchive
    if(Employee.current_employee.popv_admin?)
        @record = Valve.find(params[:id])
        @record.unarchive
    end
    @json = {:success => true}
    render :text => @json.to_json
  end

  #duplicates this valve
  def clone
    @valve = Valve.find(params[:id])


    if(!params[:new_valve_code].blank?)
      @new_valve = @valve.deep_clone(params[:new_valve_code])
      if(@new_valve.valid?)
        @json = {:success => true, :count => 1, :record => @new_valve, :original_valve_code => @valve.valve_code }
      else
        @json = {:success => false, :errors => @new_valve.errors.full_messages, :original_valve_code => @valve.valve_code}
      end
    else
      @json = {:success => false, :errors => "No Valve Code Specified", :original_valve_code => @valve.valve_code}
    end


    render :json => @json.to_json
  end

  def all_pdf
  	@report = ValvesReport.all_pdf(params)
    send_data(@report.generate, :type => @report.content_type, :filename => @report.title)

#    print_string = "#{ENV['REPORT_USER_COMMAND']} /usr/local/reportman/printreptopdf -paramPVALVEIDS='0' #{RAILS_ROOT}/reports/valve_sheet_linux.rep"
#
#    logger.error "PDF Command: #{print_string}"
#    data = `#{print_string}`
#
#    send_data(data, :type => "application/pdf", :filename => "ALL_VALVES_SHEET.pdf")
  end

  def comparison_pdf
  	@report = ValvesReport.comparison_pdf(params)
    send_data(@report.generate, :type => @report.content_type, :filename => @report.title)

	end

  def pdf
  	@report = ValvesReport.pdf(params)
    send_data(@report.generate, :type => @report.content_type, :filename => @report.title)

#  	valve = Valve.find(params[:id])
#

#    print_string = "#{ENV['REPORT_USER_COMMAND']} /usr/local/reportman/printreptopdf -paramPVALVEIDS='#{params[:id]}' #{RAILS_ROOT}/reports/valve_sheet_linux.rep"
#
#    logger.error "PDF Command: #{print_string}"
#    data = `#{print_string}`
#
#    send_data(data, :type => "application/pdf", :filename => "VALVE_SHEET_#{valve.valve_code}.pdf")
  end

  	def add_manufacturer
  		{"manufacturer_id"=>"BUTTERSWORTH", "resource"=>"manufacturers_valves", "valve_id"=>"4062", "figure_no"=>""}
  		@valve = Valve.find(params[:valve_id])
  		@valve.add_or_create_manufacturer(params[:manufacturer_id], params[:figure_no])
  		render :json => {:success => true}
 	end

 	def edit_manufacturer
		@manufacturer_valve = ManufacturersValve.find_by_id(params[:manufacturers_valves_id])
		if @manufacturer_valve.present?
      logger.error "Manufacturers Valve is present"
			@manufacturer_valve.figure_no = params[:figure_no]
			@manufacturer_valve.save!
	 	end
   logger.error "Manufacturers Valve is NOT present"
  		render :json => {:success => false}
	end

	def delete_manufacturer
		@manufacturer_valve = ManufacturersValve.find_by_id(params[:manufacturers_valves_id])
		if @manufacturer_valve.present?
		 	@manufacturer_valve.destroy
	 	end
 		render :json => {:success => true}
	end

  def supersede_manufacturer
    manufacturer_valve = ManufacturersValve.find_by_id(params[:manufacturers_valves_id])
    if manufacturer_valve.present?
      mv = OldManufacturersValve.new(:manufacturer_id => manufacturer_valve.manufacturer_id,
                                  :valve_id => manufacturer_valve.valve_id,
                                  :figure_no => manufacturer_valve.figure_no)
      if(mv.valid?)
        manufacturer_valve.destroy
        mv.save!
      else
        render :json => {:success => false, :errors => mv.errors.full_messages}
        return
      end

    end
    render :json => {:success => true}
  end
  #reverse the process
  def undo_supersede_manufacturer
    manufacturer_valve = OldManufacturersValve.find_by_id(params[:manufacturers_valves_id])
    if manufacturer_valve.present?
      mv = ManufacturersValve.new(:manufacturer_id => manufacturer_valve.manufacturer_id,
                                  :valve_id => manufacturer_valve.valve_id,
                                  :figure_no => manufacturer_valve.figure_no)
      if(mv.valid?)
        manufacturer_valve.destroy
        mv.save!
      else
        render :json => {:success => false, :errors => mv.errors.full_messages}
        return
      end

    end
    render :json => {:success => true}
  end

    # Renders a JSON object with the PipingClassDetails that are associated
    # with the Valve ID specified in params[:id].
    def related_valve_components
      @records = []

      if !params[:id].blank?
        @valve = Valve.find(params[:id])
        @records = @valve.get_valve_components
      end

      @json = {:success => true, :records => @records}

      render :json => @json
    end

    # Renders a JSON object with the PipingClassDetails that are associated
    # with the Valve ID specified in params[:id].
    def related_manufacturers
        @records = []

        if !params[:id].blank?
            @valve = Valve.find(params[:id])
            @records = @valve.get_manufacturers
        end

        @json = {:success => true, :records => @records}

        render :text => @json.to_json
    end

        # Renders a JSON object with the PipingClassDetails that are associated
    # with the Valve ID specified in params[:id].
    def related_old_manufacturers
        @records = []

        if !params[:id].blank?
            @valve = Valve.find(params[:id])
            @records = @valve.get_old_manufacturers
        end
        @json = {:success => true, :records => @records}

        render :text => @json.to_json
    end



    # Renders a JSON object with the PipingClassDetails that are associated
    # with the Valve ID specified in params[:id].
    def related_piping_classes
        @records = []

        if !params[:id].blank?
            @records = PipingClassDetail.find_with_piping_classes_for_valve_id(params[:id])
        end

        @json = {:success => true, :records => @records}

        render :text => @json.to_json
    end

    def related_piping_references
        @records = []

        if !params[:id].blank?
            @valve = Valve.find(params[:id])
            @records = @valve.get_piping_references
        end

        @json = {:success => true, :records => @records}

        render :text => @json.to_json
    end

     # Renders a JSON object with the ValvesComponents that are associated
    # with the Valve ID specified in params[:id].
    #if not valve id is specified, return all valve components
    def valve_components
      @records = []

      if !params[:id].blank?
        our_components = Valve.find(params[:id]).valves_valve_components
      else
        our_components =[]
      end
        records = []
        all_comps = ValveComponent.find(:all, :order => 'order_numbering ASC')

        all_comps.each do |comp|
          contained = false
          contained_rec = nil
          our_components.each do |rec|
            if(rec.valve_component.component_name == comp.component_name)
              contained = true
              contained_rec = rec
              break
            end
          end
          #if we already have that record
          if(contained)
            #we want the valves_valve_component_id if it's available
            this_comp = contained_rec.sext_data
            this_comp['valves_valve_component_id'] = contained_rec.id
            records << this_comp

          else
            #this is just to match the JSONstore on the client side
            this_comp = comp.sext_data
            this_comp['valve_component_id'] = comp.id
            records << this_comp
          end
        end


      json = {:success => true, :records => records, :count => records.length}
      render :json => json
    end
    def save_valve_components


      valve = Valve.find(params[:id])
      this_valves_valve_components = valve.valves_valve_components
      valve_components = ActiveSupport::JSON.decode(params[:valve_components])

      valve_components.each do |comp|
        #we have a valve_component_id  for each valve
        if(comp['valve_component_id'].blank?)
          json = {:success => false, :errors => 'missing component id!'}
          render :json => json
        end
        if(!comp['valves_valve_component_id'].blank?)
          vvc = ValvesValveComponent.find(comp['valves_valve_component_id'])
          #if we have a valves_valve_component_id and no text we can delete that valve_valve_component
          if(comp['component_text'].blank?)
            #destroy the join
            vvc.destroy
          else
            #update the component text if it's changed
            if(vvc.component_text != comp['component_text'])
              vvc.component_text = comp['component_text']
              vvc.save!
            end
          end
        elsif(!comp['component_text'].blank?)
          #create a new
          vc= ValvesValveComponent.new(
              :valve_id => valve.id,
              :valve_component_id => comp['valve_component_id'],
              :component_text => comp['component_text']
            )

            if(!vc.valid?)
              json = {:success => false, :errors => vc.errors.full_messages}
              render :json => json
            else
              vc.save!
            end

        end


        #if we have a component_text and no valves_valve_component_id then we need to create a new one
        #otherwise we should check if the component_text has changed.  If it has then we should save it
      end
      json = {:success => true}
      render :json => json
    end

end
