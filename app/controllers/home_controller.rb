# The home controller is for all static pages
#   * index.rhtml - login screen
#   * help-orders.rhtml - help window for orders
class HomeController < ApplicationController
  caches_page "help-orders"
  skip_before_filter :login_required, :except => [:superuser, :reset_messages, :menu]
  before_filter :superuser_required, :only => [:superuser, :reset_messages]
  SUPERUSERS = %w(carta cstotts telaeris_admin)
  UPDATEMESSAGE = "New! - View the <a href='/changelog'>CHANGELOG</a> to see recent changes to the application"

  def index
    flash[:error] ||= nil

    if logged_in?
      if current_employee.menu?
        redirect_to(:controller => "home", :action => "menu")
      elsif current_employee.orders?
        redirect_to(:controller => "orders", :action => "index")
      elsif current_employee.material_requests?
        if current_employee.purchasing? || current_employee.admin?
          redirect_to(:controller => "material_requests", :action => "index")
        else
          redirect_to(:controller => "material_requests", :action => "index")
        end
      elsif current_employee.web_requests?
        redirect_to(:controller => "carts", :action => "recent")
      elsif current_employee.reports?
        redirect_to(:controller => "reports", :action => "index")
      elsif current_employee.popv?
        redirect_to(:controller => "popv", :action => "index")
      else
        redirect_to(:controller => "home", :action => "menu")
      end
    end
  end

  def changelog
    #raise Rails.root.inspect
    text = IO.read(Rails.root + 'CHANGELOG').html_safe
    @log = text #BlueCloth::new(text).to_html
  end

  def reset_messages
    if request.post?
      Employee.update_all(:seen_updates => false)
      flash[:notice] = "All employees will now see an update message when they first login"
      redirect_to :action => "superuser"
    end
  end

  def menu
    render :action => "menu", :layout => "application"
  end

  def contact_us
  	@user_name = logged_in? ? current_employee.entire_full_name : ''
  	@user_email = logged_in? ? current_employee.email : ''
  end

  # generic email action
  # params[:from], params[:to], params[:subject], params[:body], params[:redirect_to]
  def email
    options = { :from => params[:email], :to => "support@telaeris.com", :subject => params[:subject], :body => "From: #{params[:user]} <#{params[:email]}>\r\nCategory: #{params[:category]}\r\nSubject:#{params[:subject]}\r\n\r\n#{params[:body]}"}
    RequestMailer.deliver_generic(options)
    flash[:notice] = "Your email was sent successfully"
    redirect_to params[:redirect]
  end

  def superuser
    if request.post?
      employee = Employee.find_by_login(params[:login])
      if employee
        self.current_employee = employee
        flash[:notice] = "Logged in as #{params[:login]}"
        redirect_to :action => "index"
      else
        flash[:notice] = "Could not find a user with login #{params[:login]}"
        redirect_to :controller => "home", :action => "superuser"
      end
    end
  end # end superuser

  private
  def superuser_required
    if !SUPERUSERS.include?(current_employee.login)
      flash[:error] = "You do not have super-user priveleges, please contact an administrator"
      redirect_to :action => :index and return
    end
  end
end
