class PipingClassDetailsController < SextController
  RESOURCE = PipingClassDetail
  before_filter :is_popv_admin, :except => [:index, :show, :add_notes]


  def increase_group_order
    RecordChangelog.enable_recording = false
    records_of_group_1 = PipingClassDetail.find(:all, :conditions => "id IN (#{params[:id]})", :order =>"piping_class_details.order ASC")

    higher_details_for_class = []
    if(records_of_group_1.length > 0)
      last_record = records_of_group_1.last
      higher_details_for_class = PipingClassDetail.find(:all, :conditions => "piping_class_id  = #{last_record.piping_class_id} AND piping_class_details.order > #{last_record.order}", :order =>"piping_class_details.order ASC")
    end
    #still need to figure out how to get the records for group 2
    #Assume that group_2 will be a contiguous set(delineated by piping_component)
    records_of_group_2 = []  #find the group of components immedately AFTER

    #if we have the last group already, we're done
    if(higher_details_for_class.length == 0)
      render :json => {:success => true}.to_json
      return
    end

    first_higher_detail = higher_details_for_class.first
    #iterate through other_details until the piping_component changes
    higher_details_for_class.each do |record|
      if(record.piping_component.parent_id.blank?) &&(record.piping_component_id != first_higher_detail.piping_component_id)
        break
      elsif(!record.piping_component.parent_id.blank?) &&(record.piping_component.parent_id != first_higher_detail.piping_component.parent_id)
        break
       else
         records_of_group_2 << record
      end
    end

    order_namespace = []
    #our overall namespace is the set of orders for all records in both groups.
    records_of_group_1.each do |record|
      order_namespace << record.order
    end
    records_of_group_2.each do |record|
      order_namespace << record.order
    end

    #we want to switch groups 1/2 so we take group 2 and assign it order#'s out of group1
    records_of_group_2.each do |g2rec|
      #take the first item off the namespace
      g2rec.order = order_namespace.shift
      g2rec.save!
    end

    #we want to switch groups 1/2 so we take group 2 and assign it order#'s out of group1
    records_of_group_1.each do |g1rec|
      #take the first item off the namespace
      g1rec.order = order_namespace.shift
      g1rec.save!
    end
    #at this point, we're done!
    RecordChangelog.enable_recording = true
    render :json => {:success => true}.to_json
  end
  def decrease_group_order
    RecordChangelog.enable_recording = false
    records_of_group_1 = PipingClassDetail.find(:all, :conditions => "id IN (#{params[:id]})", :order =>"piping_class_details.order ASC")

    lower_details_for_class = []
    if(records_of_group_1.length > 0)
      first_record = records_of_group_1.first
      lower_details_for_class = PipingClassDetail.find(:all, :conditions => "piping_class_id  = #{first_record.piping_class_id} AND piping_class_details.order < #{first_record.order}", :order =>"piping_class_details.order ASC")
    end


    #still need to figure out how to get the records for group 2
    #Assume that group_2 will be a contiguous set(delineated by piping_component)
    records_of_group_2 = []  #find the group of components immedately AFTER

    #if we have the last group already, we're done
    if(lower_details_for_class.length == 0)
      render :json => {:success => true}.to_json
      return
    end

    first_higher_detail = lower_details_for_class.last
    #iterate through other_details BACKWARDS until the class_changes
    lower_details_for_class.reverse_each do |record|
      if(record.piping_component.parent_id.blank?) &&(record.piping_component_id != first_higher_detail.piping_component_id)
        break
      elsif(!record.piping_component.parent_id.blank?) &&(record.piping_component.parent_id != first_higher_detail.piping_component.parent_id)
        break
       else
         records_of_group_2 << record
      end
    end


    order_namespace = []
    #our overall namespace is the set of orders for all records in both groups.
    #The order_namespace MUST BE IN ORDER
    records_of_group_2 = records_of_group_2.sort {|x,y| x.order <=> y.order }
    records_of_group_2.each do |record|
      order_namespace << record.order
    end

    records_of_group_1.each do |record|
      order_namespace << record.order
    end


    #we want to switch groups 1/2 so we take group 2 and assign it order#'s out of group1

    #we want to switch groups 1/2 so we take group 2 and assign it order#'s out of group1
    records_of_group_1.each do |g1rec|
      #take the first item off the namespace
      g1rec.order = order_namespace.shift
      g1rec.save!
    end
    records_of_group_2.each do |g2rec|
      #take the first item off the namespace
      g2rec.order = order_namespace.shift
      g2rec.save!
    end

    #at this point, we're done!
    RecordChangelog.enable_recording = true
    render :json => {:success => true}.to_json
  end
  def increase_order
    begin
      RecordChangelog.enable_recording = false
      detail = PipingClassDetail.find(params[:id])
      original_detail_order = detail.order
      #find the detail immediately below it
      next_detail = PipingClassDetail.find(:first,
                :conditions => "piping_class_id = #{detail.piping_class_id} AND piping_class_details.order > #{original_detail_order}",
                :order => "piping_class_details.order ASC")

      #switch orders
      if(!next_detail.blank?)
        detail.order = next_detail.order
        next_detail.order = original_detail_order
        next_detail.save!
        detail.save!
      end
      render :json => {:success => true}.to_json
    rescue
      render :json => {:success => false}.to_json
    end
    RecordChangelog.enable_recording = true
  end

  def decrease_order
    RecordChangelog.enable_recording = false
    begin
      #this is our detail
      detail = PipingClassDetail.find(params[:id])
      original_detail_order = detail.order
      #find the detail immediately below it
      previous_detail = PipingClassDetail.find(:first,
                :conditions => "piping_class_id = #{detail.piping_class_id} AND piping_class_details.order < #{original_detail_order}",
                :order => "piping_class_details.order DESC")

      if(!previous_detail.blank?)
        detail.order = previous_detail.order
        previous_detail.order = original_detail_order
        previous_detail.save!
        detail.save!
      end
      render :json => {:success => true}.to_json

    rescue
      render :json => {:success => false}.to_json
    end
    RecordChangelog.enable_recording = true
  end

  def remove_note
  	detail = PipingClassDetail.find(params[:id])
  	note = PipingNote.find(params[:piping_note_id])
  	if(!detail.nil? && !note.nil?)

  		detail.piping_notes.delete(note)
  		render :json => {:success => true, :record => detail.sext_data}.to_json
  	else

  		render :json => {:success => false}.to_json
  	end
  end

  def add_note
  	detail = PipingClassDetail.find(params[:id])
  	note = PipingNote.find(params[:piping_note_id])
  	if(!detail.nil? && !note.nil?)
  		detail.piping_notes <<  note
  		render :json => {:success => true, :record => detail.sext_data}.to_json
  	else
  		render :json => {:success => false}.to_json
  	end
  end

  def add_notes
  	#for each detail_id we want to add all of the piping_notes
  	if(!params[:piping_notes].blank?)
  		notes = []
  		note_ids = params[:piping_notes].split(',').uniq

      note_ids.each do |note_id|
  			notes << PipingNote.find(note_id)
  		end
      details = []
      detail_ids = params[:id].split(',').uniq
      detail_ids.each do |detail_id|
        if(!detail_id.blank?)
          @detail = PipingClassDetail.find(detail_id)
          details << @detail
        end
      end
  		details.each do |detail|
    		notes.each do |this_note|
  			if(!detail.piping_notes.include?(this_note))
  				detail.piping_notes << this_note
  			end
      end
		end

		render :json => {:success => true, :record => @detail.sext_data}.to_json
	else
		render :json => {:success => false}.to_json
  	end

  end

  	def prepend_text_to_descriptions
	   	ids = ActiveSupport::JSON.decode(params[:piping_class_detail_ids])
  	 	if !ids.blank?
  	 		PipingClassDetail.prepend_text_to_descriptions(ids, params[:description])
  	 		render :json => {:success => true}.to_json
 	 	else
 	 		render :json => {:success => false}.to_json
	 	end
  	end

	# deletes
	def destroy
		if params[:ids]
			params[:ids].split(',').each do |id|
				@record = klass.find(id)
				@record.destroy
			end
		else
			@record = klass.find(params[:id])
			@record.destroy
		end
		@json = {:success => true}
		render :text => @json.to_json
	end


  #def index(options = {})
  #  order = params[:sort] + " " + params[:dir] if params[:dir] && params[:sort]
  #  @records = PipingClassDetail.paginate(:start => params[:start] , :limit => params[:limit], :order => order, :conditions => #"piping_class_id = #{params[:piping_class_id]}")
  #  @count = PipingClassDetail.count
  #  @json = { :count => @count, :records => @records.map { |l| l.data } }
  #  render :json => {:records => @records, :count => @records.size }.to_json
  #end
  def filter_conditions
	filter = FilterFoo.new
	filter.equal params[:piping_class_id], "piping_class_details.piping_class_id"
	return filter
  end


end
