# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  RESOURCE = nil
  skip_before_filter :login_required, :only => [:new, :create]
  
  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_to '/'
      flash[:notice] = "Logged in successfully"
    else
      flash[:error] = "Incorrect login/password combination"
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    self.current_user = :false
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to '/'
  end
end
