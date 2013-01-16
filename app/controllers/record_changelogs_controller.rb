class RecordChangelogsController < SextController
	RESOURCE = RecordChangelog
skip_before_filter :is_popv_admin, :only => [:get_attachment]

  # Main gateway for grabbing PipingReferences from the server.
  def get_attachment
    log_item = RecordChangelog.find(params[:id])
    if(log_item.attachment)
      debugger
      send_file log_item.attachment.path, {
        :filename => log_item.attachment_file_name,
        :type => log_item.attachment.content_type
        # Can be used if lighttpd or Apache
        # have been configured for X-Sendfile:
        # :x_sendfile => true
      }
    end
  end
# lists out records
  # for searching, pass in params[:query]
  # for filtering, pass in params[:filter] = {attributes}
  def index(should_render=true)
    if(params[:controller] == 'sext') && (!params[:resource]) && (params[:action] == 'index')
      render :action => 'index' and return
    end

    limit = params[:limit] || DEFAULT_LIMIT
    start = params[:start] || DEFAULT_START
    if params[:sort]
      sort = params[:sort].include?(".") ? params[:sort] : klass.table_name + "." + params[:sort]
    else
      sort = klass.table_name + ".id"
    end

    const_order_mapping = klass.const_defined?("PAGE_ORDER_MAPPING") ? klass::PAGE_ORDER_MAPPING : {}
    dir = params[:dir] || "ASC"
    order = sort + " " + dir

    if(!params[:sort].blank?)
      if const_order_mapping.has_key?(params[:sort].to_sym)
        order = const_order_mapping[params[:sort].to_sym] + " " + dir
      end
 	  end
    order = klass.table_name + "." + order if !order.include?(".")

    if params[:order]
      order = params[:order]
    end

    filters = params[:filter].blank? ? nil : params.dup

    filters.delete(:action) if(!filters.blank?)
    search_conditions = build_search(params[:query], filters)

    select = klass.const_defined?("SEXT_SELECT_FIELDS") ? klass::SEXT_SELECT_FIELDS : nil
    if(params[:piping_class_explicit] == "true")
      search_conditions[1] = "#{params[:record_identifier]} -%"
    end
    if(params[:all])
      records = klass.find(:all, :select => select, :order => order, :conditions => search_conditions)
    elsif(params[:all_index])
      records = klass.find(:all, :order => order, :include => Sext.get_joins(klass), :conditions => search_conditions)
    else
      records = klass.find(:all, :limit => limit, :offset => start, :order => order, :include => Sext.get_joins(klass), :conditions => search_conditions)
    end

    @records = records

    records = Sext.get_data(records,true, params)

    record_count = 0
    klass.send(:with_scope, :find => { :conditions => search_conditions, :include => Sext.get_joins(klass)}) do
      record_count = klass.count
    end
    @record_count = record_count

    @json = { :records => records, :count => record_count }
    render_if should_render, :text => @json.to_json
  end

	def update_comment
		@record_changelog = RecordChangelog.find(params[:id])
		@record_changelog.update_comment(params[:comment])
		render :json => { :success => true }
	end
end
