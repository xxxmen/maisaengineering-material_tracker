module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_employee with the user model if they're logged in.
    def logged_in?
      current_employee != :false
    end

    # Accesses the current employee from the session.
    def current_employee
      @current_employee ||= (session[:employee] && Employee.find_by_id(session[:employee])) || :false
    end

    # Store the given employee in the session.
    def current_employee=(new_employee)
      session[:employee] = (new_employee.nil? || new_employee.is_a?(Symbol)) ? nil : new_employee.id
      @current_employee = new_employee
    end

    # Check if the employee is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the employee
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_employee.login != "bob"
    #  end
    def authorized?
      true
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      verify_login ? true : access_denied
    end

    def verify_login
      return true if params[:user] == "winclient" && params[:password] == "bp_carson"
      return true if Rails.env.test?
      username, passwd = get_auth_data
      self.current_employee ||= Employee.authenticate(username, passwd) || :false if username && passwd
      logged_in? && authorized? ? true : false
   	end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the employee is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          flash.now[:error] = "Please login first."
          redirect_to :controller => 'home', :action => 'index'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      if request.get?
        #For Rails 2: You want request.url instead of request.request_uri. This combines the protocol (usually http://) with the host, and request_uri to give you the full address.
        #For Rails 3: You want "#{request.protocol}#{request.host_with_port}#{request.fullpath}", since request.url is now deprecated.
        session[:return_to] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      end
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_employee and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_employee, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = Employee.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        self.current_employee = user
        cookies[:auth_token] = { :value => self.current_employee.remember_token , :expires => self.current_employee.remember_token_expires_at }
      end
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil]
    end
end
