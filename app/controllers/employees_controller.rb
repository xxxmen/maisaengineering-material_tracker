class EmployeesController < ApplicationController
  before_filter :find_employee, :only => [:edit, :update, :destroy]  
  before_filter :check_query, :only => [:search]
      
  def index
      method = params.has_key?(:users_only) ? 'list_users_only' : 'list'
      Employee.filter(params) do
          @employees = Employee.send(method, params, :order => "employees.last_name", :sort => "asc", :include => "company")
      end
  end
  
  def search
    method = params.has_key?(:users_only) ? 'search_users_only' : 'full_text_search'
    @employees = Employee.send(method, params)
    return_search(@employees)    
  end
  
  def new
    @employee = Employee.new
    @employee.role = Employee::REQUESTING if current_employee.requesting_admin?
    render :action => "edit"
  end
  
  def telephone
    name = params[:id].strip
    
    if name =~ /\d+/
      id = name
    else
      name =~ /\((\d+)\)$/
      id = $1
    end
    
    @employee = Employee.find_by_id(id)
    if @employee
      telephone = @employee.telephone || ''
      render :text => telephone
    else
      render :text => ""
    end
  end
            
  def create
    @employee = Employee.new
    @employee.role = Employee::REQUESTING if current_employee.requesting_admin?
    save_and_show!
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = "There was a problem saving this employee"
    render :action => "edit"
  end
  
  def update
    save_and_show!
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = "There was a problem saving this employee: #{@employee.errors.full_messages.join(', ')}"
    render :action => "edit"
  end

  def destroy
    @employee.destroy
    redirect_to employees_path
  end
  
  private
  def save_and_show!
    @employee.update_attributes!(params[:employee])
    flash[:notice] = msg_for("Employee", @employee.first_name, @employee)
    redirect_to employees_path
  end
  
  def find_employee
    @employee = Employee.find(params[:id])
  end
end