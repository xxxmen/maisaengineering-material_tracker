module EmployeesHelper
  # Should we disable the form controls for employee's profile?
  # This includes the badge number, email, etc..
  def d_prof?(user, options = {})
    !current_employee.edit_profile?(user, options)
  end
  
  # Should we disable the form controls for employee's login details?
  # This includes login // password // password confirmation
  def d_login?(user)
    !current_employee.edit_login?(user)
  end
  
  def filter_url(filter_hash = {})
    new_params = params.merge(filter_hash)
    
    url = "/employees?"
    
    if new_params[:company]
      url += "&amp;company=" + new_params[:company].to_s
    end
    if new_params[:role]
      url += "&amp;role=" + new_params[:role].to_s
    end
    
    return URI.escape(url)
  end
end