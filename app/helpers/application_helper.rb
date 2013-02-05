module ApplicationHelper
  include Listable::ViewHelper

  # Sets the Site Name to whatever is stored in the configured Constant
  def deploy_site_name
    Object.const_defined?('DEPLOY_SITE_NAME') ? Object.const_get('DEPLOY_SITE_NAME') : ""
  end

  def resource_enabled?(controller_name = nil)
    controller_name ||= params[:controller]
    ResourcePermission.is_enabled?(controller_name)
  end


  # Really only used for the Tickets Controller and Views.
=begin
  def parent_layout(layout)
    @content_for_layout = self.output_buffer
    self.output_buffer = render(:file => "layouts/#{layout}")
  end
=end

  #replaced parent_layout to be work in rails 3
  #Ref http://m.onkey.org/nested-layouts-in-rails-3   from the comments
  def parent_layout(layout)
    @view_flow.set(:layout,output_buffer)
    self.output_buffer = render(:file => "layouts/#{layout}")
  end


  def selected_if(path)
    if path == "mine"
      params[:status].blank? || params['status'] == "mine" ? "selected='selected'" : ""
    else
      params[:status] == path ? "selected='selected'" : ""
    end
  end

  def select_filter_if(condition)
    if condition
      return "selected='selected'"
    else
      return ''
    end
  end

  def show_update_message?
    return false if !logged_in?

    if !current_employee.seen_updates
      current_employee.update_attributes!(:seen_updates => true)
      return true
    else
      return false
    end
  end

  def list_options(array, display = "id", value = nil, convert = false, include_blank = false)
    value ||= display
    options = array.map { |i| [i.send(display), i.send(value)] }
    options = include_blank ? options.unshift([include_blank, nil]) : options
    convert ? options_for_select(options) : options
  end

  def remote_link(name, url, image = nil, html_options = {}, parameters = [])
    parameters = parameters.map { |p| "'" + p.to_s + "'" }
    options = {}
    options[:url] = url
    options[:with] = "Form.serializeThese([#{parameters.join(', ')}])" if parameters.size > 0
    options[:loading] = "loadingReq('#{image}')" if image
    options[:complete] = "completeReq('#{image}')" if image

    link_to_function name, remote_function(options), html_options
  end

  def remote_button(name, url, image = nil, html_options = {}, parameters = [])
    parameters = parameters.map { |p| "'" + p.to_s + "'" }
    options = {}
    options[:url] = url
    options[:with] = "Form.serializeThese([#{parameters.join(', ')}])" if parameters.size > 0

    button = html_options[:id] || ""

    options[:loading] = "loadingReq('#{image}', '#{button}')" if image
    options[:complete] = "completeReq('#{image}', '#{button}')" if image
    button_to_function name, remote_function(options), html_options
  end

  def toggle_edit(object)
    form = "'#{dom_id(object, :edit)}'"
    anchor = "'#{dom_id(object, :anchor)}'"
    "$(#{anchor}).toggle(); $(#{form}).toggle(); $(#{form}).focusFirstElement(); return false;"
  end

  def edit_for(object, method)
    render(:partial => "shared/edit_for", :locals => { :object => object, :method => method })
  end

  def warehouse_view?
    current_employee.warehouse?
  end

  def receiving_view?
    current_employee.receiving?
  end

  def not_purchasing?
    !current_employee.purchasing?
  end

  def not_planning?
    !current_employee.planning?
  end

  def not_admin?
    if params[:action] == "new"
      return false
    else
      !current_employee.popv_admin? && !current_employee.admin? && !current_employee.warehouse_admin?
    end
  end

  def purchasing_view?
    current_employee.purchasing? || current_employee.admin? || current_employee.popv_admin?
  end

  def planning_view?
    current_employee.planning?
  end

  def requesting_view?
    current_employee.requesting?
  end

  def class_for(controller, params = {})
    params[:controller] == controller ? "selected" : ""
  end

  def table_header(instructions, width = "")
    return "<tr class=\"instructions\"><td width=\"#{width}\">#{instructions}</td><td>&nbsp;</td></tr>"
  end

  def nbsp(text)
    text.blank? ? "&nbsp;" : h(text)
  end

  # gsub doesn't work, it strips a lot of numbers out that shouldn't be stripped
  def wrap_nos(text)
    return text
  end

  def format_desc(text)
    text = nbsp(text)
    # don't use wrap_nos for now, truncate should take care of long order numbers
    # text = wrap_nos(text)
    text = truncate(text, :length => 120)
    return text
  end

  def table_row(&proc)
    concat("<tr><td>&nbsp;</td><td>", proc.binding)
    yield
    concat("</td></tr>", proc.binding)
  end

  def format_date(date, format_string = "%m/%d/%y")
    date ? date.strftime(format_string) : ""
  end

  def format_time(time)
    time ? time.strftime('%I:%M%p %m/%d/%Y') : ''
  end

  def default_for(text, default)
    text.blank? ? h(default) : h(text)
  end

  def windowed_pagination_links(pagingEnum, options)
    link_to_current_page = options[:link_to_current_page]
    always_show_anchors = options[:always_show_anchors]
    padding = options[:window_size]

    current_page = pagingEnum.page
    html = ''

    #Calculate the window start and end pages
    padding = padding < 0 ? 0 : padding
    first = pagingEnum.page_exists?(current_page  - padding) ? current_page - padding : 1
    last = pagingEnum.page_exists?(current_page + padding) ? current_page + padding : pagingEnum.last_page

    # Print start page if anchors are enabled
    html << yield(1) if always_show_anchors and not first == 1

    # Print window pages
    first.upto(last) do |page|
      (current_page == page && !link_to_current_page) ? html << page : html << yield(page)
    end

    # Print end page if anchors are enabled
    html << yield(pagingEnum.last_page) if always_show_anchors and not last == pagingEnum.last_page
    html
  end

  def get_order(params, field)
    if params[:order_by] == field && params[:desc].nil?
      return "true"
    else
      return nil
    end
  end

  def o(&block)
    yield
  rescue NoMethodError
    ""
  end

  def link_to_back(name = "Cancel Changes & List All")
    # link_to name, "javascript:history.go(-1)"
    if params[:cart]
      link_to name, "/carts"
    else
      link_to name, url_for(:action => :index)
    end
  end

  def link_to_desc(object, options = {})
    options[:method] ||= :description
    options[:default] ||= "No Description"
    options[:path] ||= url_for(:action => :edit, :id => object)
    options[:html] ||= {}

    text = object.send(options[:method])
    text = options[:default] if text.blank?
    if options.has_key?(:truncate)
      text = truncate(text, options[:truncate])
    end

    link_to h(text), options[:path], options[:html]
  end

  def tabelize(collection)
    collection.each_with_index do |object, index|
      yield(object, index % 2 == 1 ? "odd" : "even")
    end
  end

  def display_unless(condition)
    condition ? "style='display: none;'" : ""
  end

  def display_if(condition)
    display_unless !condition
  end

  def form_id(record)
    record.new_record? ? dom_id(record) : dom_id(record, :edit)
  end

  def form_save(record)
    "Telaeris.skipConfirm = true;$('#{form_id record}').submit();return false;"
  end

  def get_location(location)
    location.blank? ? "(No Location)" : location
  end

  def col_for_warehouse
    warehouse_view? ? "1" : "2"
  end

  def default_request_params
    if current_employee.admin? || current_employee.popv_admin? || current_employee.purchasing? || current_employee.warehouse? || current_employee.warehouse_admin?
      return { :status => "all" }
    else
      return {}
    end
  end

  # def link_to_sort(name, column)
  #   link_to(name, :q => params[:q], :action => params[:action], :order_by => column, :desc => get_order(params, column), :year => params[:year]) + " " +
  #   get_order_image(params, column)
  # end

  def current_time
    Time.now.strftime("%I:%M%p on %m/%d/%y")
  end

  def link_to_note(note)
    "<a href='##{dom_id note}' title='#{h note.note_text}' id='#{dom_id note}' onclick='PipeBuilder.showNote(this); return false;' >#{note.id}</a>"
  end

end
