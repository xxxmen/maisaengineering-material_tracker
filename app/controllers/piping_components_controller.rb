class PipingComponentsController < SextController
  	RESOURCE = PipingComponent

  	def destroy
  		super(false)
	    render :json => @json
	rescue ActiveRecord::ActiveRecordError => e
    	@json = {:success => false, :message => e.message}
    	render :json => @json
 	end


  #override the default here
  def create(should_render=true)
    @record = klass.new
    save_and_render
  end

  def save_and_render(should_render=true)
    attributes = {}
    params.each do |key, value|
      next if key == "id" || key == "action" || key == "controller"
      if(@record.class.columns.detect { |c| c.name == key }.class == :binary)
        data = value
        unless data.blank?
          data.rewind
          attributes[key] = data.read unless data.size == 0
        end
      else
        attributes[key] = value if @record.respond_to?(key + "=")
      end
    end

    @record.attributes = attributes
    if(attributes['subcomponent_ids'])&&(!attributes.subcomponent_ids.blank?)
      #don't bother saving the main record if there are subcompontts
      ids = attributes.subcomponent_ids.split(',')
      ids.each do |this_id|
        rec = klass.new
        rec.attributes = attributes
        rec.piping_component_id = this_id
        rec.save!
      end
    else
      @record.save!
    end

    @json = {:success => true, :record => @record.sext_data}
    render_if should_render, :text => @json.to_json and return
  rescue ActiveRecord::RecordInvalid
    @json = {:success => false, :errors => {}}
    @record.errors.each { |key, val| @json[:errors][key] = val }
    render_if should_render, :text => @json.to_json and return
  end

 	# Gets a list of Piping Classes that the passed in PipingComponentID is
 	# associated with.
 	def associated_piping_classes
		@piping_component = PipingComponent.find(params[:id])
		@classes = @piping_component.get_related_piping_classes
		render :json => {:success => true, :records => [{:class_codes => @classes}], :count => 1}
	end
end
