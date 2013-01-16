# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  skip_before_filter :login_required

  def create
    self.current_employee = Employee.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_employee.remember_me
        cookies[:auth_token] = { :value => self.current_employee.remember_token , :expires => self.current_employee.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => "home", :action => "index")
    else
      flash[:error] = "Incorrect username/password combination"
      redirect_to(:controller => "home", :action => "index", :login => params[:login])
    end
  end

  def destroy
    # self.current_employee.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash.now[:notice] = "You have been logged out."
    redirect_to :controller => "home", :action => "index"
  end
  
  # Logs the user in as the popv user and redirects them to the popv index page.
  def login_as_popv_viewer
  	self.current_employee = Employee.find_or_create_popv_viewer

    if logged_in?
        flash[:notice] = 'Welcome to WebPOPV'
        redirect_to(:controller => "popv", :action => "index") and return
    else
        flash[:error] = 'Sorry, you could not log into WebPOPV for some reason. Please contact support@telaeris.com'
        redirect_back_or_default(:controller => "home", :action => "index") and return    
    end
  end  
end
