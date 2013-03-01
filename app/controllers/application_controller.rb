class ApplicationController < ActionController::Base
  protect_from_forgery

  include AuthenticatedSystem
  #include ExceptionNotification::ExceptionNotifiable

  before_filter :login_from_cookie
  before_filter :login_required
  before_filter :set_cattr_employee
  before_filter :get_admin_message

  #ExceptionNotification configuration for rails 3.2
  before_filter :log_additional_data

  #Make it so it doesn't use a layout

  #self.error_layout = true
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => '74daedc5835bfdd5f15246381b0b7151'  

  # Hopefully this fixes the 'Microsoft Office Protocol Discovery' issue we
  # were having with /doc/General_Notes.doc. This should filter all requests
  # with HTTP_METHOD = 'OPTIONS' and render a 418 error (I'm a teapot),
  # preventing an Exception Notifier from being emailed EVERY time...
  # See also: config/routes.rb, lib/extra_http_verbs.rb

  #TODO remove skip_before_filter  :verify_authenticity_token  when upgrading to rails 3.2 if supports by default
  skip_before_filter  :verify_authenticity_token #to escape form WARNING: Can't verify CSRF token authenticity rails 3.1

  def options_for_mopd
    render :nothing => true, :status => 418
  end

  protected
  # Returns the class that the controller is using as its main resource
  def resource
    self.class::RESOURCE || (raise NotImplementedError, "#{self.class} does not define a RESOURCE"; nil)
  end

  # Blocks access to the "popv" user account for all controllers that subclass
  # from ApplicationController, which has been set to have the "POPV_VIEWER" role.
  # To allow access, override authorized? in the appropriate controller,
  # but be aware this might allow even the public "popv" account to see and use
  # the resources in the overridden controller.
  def authorized?
    !current_employee.popv_viewer?
  end

  #an admin can do anything by default
  def is_popv_admin
    return current_employee.popv_admin?
  end

  # Allows for validation based on a Vendor-specific access key
  def access_key_required
    unless access_key_found?
      redirect_to '/404' and return false
    end
  end

  def access_key_found?
    @vendor = Vendor.find_by_id(params[:vendor_id])
    if @vendor && @vendor.access_key == params[:access_key]
      @vendor_id = @vendor.id
      true
    else
      false
    end
  end

  # Controls access to Controllers based on the ResourcePermissions table.
  def resource_enabled?(controller_name = nil)
    controller_name ||= params[:controller]
    unless ResourcePermission.is_enabled?(controller_name)
      flash[:error] = "You are not authorized to access this page."
      redirect_to main_menu_path and return false
    end
  end

  # Renders @json if either condition is true or the condition does not exist
  # pass in a FALSE value in order to not render
  def render_if(render_option = nil)
    render :json => @json.to_json if(render_option.nil? || render_option)
  end

  def render_json(json, options={})
    callback, variable = params[:callback], params[:variable]
    response = begin
      if callback && variable
        "var #{variable} = #{json};\n#{callback}(#{variable});"
      elsif variable
        "var #{variable} = #{json};"
      elsif callback
        "#{callback}(#{json});"
      else
        json
      end
    end
    render({:content_type => :js, :text => response}.merge(options))
  end

  def user
    current_employee
  end

  def current_time
    Time.now.strftime("%I:%M%p on %m/%d/%y")
  end

  def msg_for(name, display, value)
    edit_path = url_for(:action => :edit, :id => value)
    "#{name} <a href=\"#{edit_path}\">'#{display}'</a> saved successfully at #{current_time}".html_safe
  end

  # Filters used in all controllers go here
  def check_query
    if params[:q].blank?
      flash[:error] = "Please enter a phrase to search with."
      redirect_to(:action => :index) and return false
    end
  end

  def return_search(results, options={})
    if results.size == 0
      flash[:error] = "There were no search results for '#{params[:q]}'"
        #redirect_to({:action => :index}.merge(options)) and return
        redirect_to(:action => :index) and return
=begin
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError #No HTTP_REFERER was set in the request to this action, so redirect_to :back
        redirect_to :action => :index
      end
=end
    elsif results.size == 1 && current_employee.direct_search?
      flash[:notice] = "Found one record and redirected to your search result"
      redirect_to(:action => :edit, :id => results.to_a[0])
    else
      flash.now[:notice] = "Found #{results.count} result(s) for '#{params[:q]}'"
      render(:action => :index)
    end
  end

  def set_cattr_employee
    Employee.current_employee = self.current_employee if logged_in?
  end

  def get_admin_message
    @admin_message = Admin::Message.get_message
  end

  #protected
  #exception_data :additional_data
  #def additional_data
  #  { :document => @document,
  #    :person => @person }
  #end

  #ExceptionNotification configuration for rails 3.2
  protected
  def log_additional_data
    request.env["exception_notifier.exception_data"] = {
        :document => @document,
        :person => @person
    }
  end
end
