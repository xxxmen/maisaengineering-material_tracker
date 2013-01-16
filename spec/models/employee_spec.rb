require File.dirname(__FILE__) + '/../spec_helper'

describe Employee do  
  fixtures :companies
  before(:each) do
    @employee = Employee.new
  end
  
  it "should have the roles ADMIN, WAREHOUSE, PURCHASING, PLANNING, WAREHOUSEADMIN and REQUESTING" do
    [:admin?, :warehouse?, :purchasing?, :planning?, :requesting?, :warehouse_admin?].each do |method|
      @employee.should respond_to(method)
    end
  end
  
  it "should be invalid without a first or last name" do
    first = create_employee(:first_name => nil)
    last = create_employee(:last_name => nil)
    
    first.should have(1).error_on(:first_name)
    last.should have(1).error_on(:last_name)
  end
  
  it "should not let you create a role outside of inclusion" do
    user = create_employee(:role => 500)
    user.should have(1).error_on(:role)
  end
  
  it "should be invalid given a strange badge number" do
    user = create_employee(:badge_no => "12FD")
    user.should have(1).error_on(:badge_no)
  end
  
  it "should default to warehouse, and include warehouse_admin for that check" do
    @employee.should be_warehouse

    [Employee::WAREHOUSE, Employee::WAREHOUSE_ADMIN, -1, 199, nil].each do |role_value|
      @employee.role = role_value
      @employee.should be_warehouse
    end
    
    @employee.role = Employee::WAREHOUSE_ADMIN
    @employee.should_not be_warehouse(true)  # exclude_admin set to true should not count the admin as a warehouse member
  end
  
  it "should see requesting_admins as part of requesting" do
    @employee.role = Employee::REQUESTING
    @employee.should be_requesting
    
    @employee.role = Employee::REQUESTING_ADMIN
    @employee.should be_requesting
    @employee.should_not be_requesting(true)  # exclude_admin is set to true
  end
  
  it "should count purchasing as planning and vice versa" do
    @employee.role = Employee::PURCHASING
    @employee.should be_purchasing
    @employee.should be_purchasing(true)      # exclude_planning is set to true
    @employee.should be_planning
    @employee.should_not be_planning(true)    # exclude_purchasing is set to true
    
    @employee.role = Employee::PLANNING
    @employee.should be_planning
    @employee.should be_planning(true)
    @employee.should be_purchasing
    @employee.should_not be_purchasing(true)
  end
  
  it "should need details if user is an admin, purchaser, or planner" do
    @employee.role = Employee::WAREHOUSE
    @employee.need_details?.should_not == true
    
    [Employee::ADMIN, Employee::PURCHASING, Employee::PLANNING].each do |role_value|
      @employee.role = role_value
      @employee.need_details?.should == true
    end
  end
  
  it "should change roles when given a new one" do
    @employee.role = Employee::ADMIN
    @employee.should be_admin
    
    @employee.role = Employee::PLANNING
    @employee.should be_planning
    @employee.should be_new_record
  end
  
  it "should list out the options for roles" do
    expected = [
      ['Admin', 			Employee::ADMIN],
      ['Warehouse', 		Employee::WAREHOUSE], 
      ['Warehouse Admin', 	Employee::WAREHOUSE_ADMIN],
      ['Purchaser', 		Employee::PURCHASING], 
      ['Planner', 			Employee::PLANNING],
      ['Requester', 		Employee::REQUESTING], 
      ['Requester Admin', 	Employee::REQUESTING_ADMIN],
      ['Receiver', 			Employee::RECEIVING], 
      ['Engineer', 			Employee::ENGINEER],
      ["POPV Viewer", 		Employee::POPV_VIEWER], 
      ["POPV Admin", 		Employee::POPV_ADMIN]
    ]
    
    Employee.options_for_role.should == expected
  end
  
  it "should filter anyone out who does not have a login OR crypted_password" do
    employees = Employee.find(:all)
    users_only = Employee.find(:all, :conditions => "login IS NOT NULL AND crypted_password IS NOT NULL")
    
    # make sure the fixtures are good
    employees.size.should_not == users_only.size
    users_only.size.should > 1
    
    # here's the actual test
    results = Employee.list_users_only({}).to_a.map(&:id).sort
    results.size.should > 1
    results.size.should_not == employees.size
    results.should == users_only.map(&:id).sort
  end
  
  it "should list all companies to which at least one employee belongs to" do
    employees = Employee.find(:all, :include => :company)
    companies = []
    
    employees.each do |employee|
      if !companies.include?(employee.company)
        companies << employee.company
      end
    end
    
    Employee.all_companies == companies.sort { |a, b| a.name <=> b.name }
  end
  
  it "should always be linked to a cart, if one doesnt exist it should create it from 'last_cart'" do
    @me = Employee.find(:first)
    @me.carts.each { |c| c.destroy }
    @me.carts.reload
    @me.carts.size.should == 0
    
    cart = @me.last_cart
    cart.employee_id.should == @me.id
    cart.requested_by_id.should == @me.id
    @me.carts.reload
    @me.carts.size.should == 1
    
    next_cart = @me.last_cart
    next_cart.should == cart
    @me.carts.reload
    @me.carts.size.should == 1
  end
  
  it "should give a user's name and email in email TO field format" do
    @me = Employee.new
    @me.first_name = "Hugh"
    @me.last_name = "Bien"
    @me.name_and_email.should be_blank
    
    @me.email = "hugh@telaeris.com"
    @me.name_and_email.should == "Hugh Bien <hugh@telaeris.com>"
    
    @me.mi = "D"
    @me.name_and_email.should == "Hugh D Bien <hugh@telaeris.com>"
  end
  
  it "should display an employee's full name in different formats" do
    @me = Employee.new
    @me.first_name = "Hugh"
    @me.last_name = "Bien"
    @me.mi = "D"
    
    @me.short_name.should == "H. Bien"
    @me.full_name.should == "Bien, Hugh D"
    @me.entire_full_name.should == "Hugh D Bien"
    
    @me.mi = nil
    @me.entire_full_name.should == "Hugh Bien"
    
    @me.mi = "D"
    @me.last_name = nil
    @me.full_name.should == "Hugh D"
    
    @me.id = 1
    @me.last_name = "Bien"
    @me.entire_name_with_id.should == "Hugh D Bien (1)"
  end
        
  it "should fail validation without a company" do
    employee = create_employee(:company_id => nil)
    
    employee.should have(1).error_on(:company_id)
    employee.error_on(:company_id).should == ["can't be blank"]
  end
  
  it "should fail validation with duplicate login" do
    first = create_employee(:login => "cstrife")
    second = create_employee(:login => "cstrife")
    
    first.should be_valid
    second.should_not be_valid
    
    second.should have(1).error_on(:login)
    second.error_on(:login).should == ["has already been taken"]
  end
  
  it "should default to the warehouse role" do
    employee = create_employee
    employee.should be_warehouse
    employee.should_not be_admin
    employee.should_not be_purchasing
    employee.should_not be_planning
    employee.should_not be_requesting    
  end
        
  it "should initialize a new order based on role" do
    employee = create_employee(:role => Employee::REQUESTING)
    employee.new_order.requester.should == employee
    
    employee = create_employee(:role => Employee::PLANNING)
    employee.new_order.planner.should == employee
  end    
    
  it "should be able to edit the profile of other users if the employee is an admin" do
    admin = create_employee(:role => Employee::ADMIN)
    req = create_employee(:role => Employee::REQUESTING)
    admin.edit_profile?(req).should == true
    admin.edit_login?(req).should == true
    
    admin.edit_profile?(admin).should == true
    admin.edit_login?(admin).should == true
  end
  
  it "should be able to edit the profile of other warehouse members if the user is a warehouse admin" do
    admin = create_employee(:role => Employee::WAREHOUSE_ADMIN)
    wh = create_employee(:role => Employee::WAREHOUSE)
    non_wh = create_employee(:role => Employee::REQUESTING)
    
    admin.edit_profile?(wh).should == true
    admin.edit_login?(wh).should == true
    
    admin.edit_profile?(non_wh).should == false
    admin.edit_login?(non_wh).should == false
  end
  
  it "should not be able to edit the profile for anyone if not a warehouse_admin or admin" do
    user = create_employee(:role => Employee::REQUESTING)
    req = create_employee(:role => Employee::REQUESTING)
    
    # Cannot edit one's own profile, but you can edit your own login/password details
    user.edit_profile?(user).should == false
    user.edit_login?(user).should == true
    
    # Cannot edit anyone else's profile OR login
    user.edit_profile?(req).should == false
    user.edit_profile?(req).should == false
  end

  it "should only need details if it's an admin or purchaser" do
    wh = create_employee(:role => Employee::WAREHOUSE)
    admin = create_employee(:role => Employee::ADMIN)
    purchase = create_employee(:role => Employee::PURCHASING)
    
    wh.need_details?.should == false
    admin.need_details?.should == true
    purchase.need_details?.should == true
  end
    
  # Determines if a user is able to edit the login/passwords for another user
  def edit_login?(user)
    # Editable if the user is an admin OR
    # the user is editing his own settings
    edit_profile?(user) || self == user
  end
    
  it "should determine whether or not one user can edit another user's profile" do
    # Admins can edit anyone's profile
    # Warehouse admins can only edit warehouse profiles
    # Requesting admin can only edit requesting profiles
    # nobody else can edit profiles
    
    rules = { Employee::ADMIN => [ Employee::WAREHOUSE, Employee::REQUESTING, Employee::PURCHASING],
              Employee::WAREHOUSE_ADMIN => [ Employee::WAREHOUSE, Employee::WAREHOUSE_ADMIN ],
              Employee::REQUESTING_ADMIN => [ Employee::REQUESTING, Employee::REQUESTING_ADMIN ] }
    rules.each do |editor_role, subject_roles|
      subject_roles.each do |subject_role|
        editor = Employee.new(:role => editor_role)
        subject = Employee.new(:role => subject_role)
        editor.edit_profile?(subject).should == true
      end
    end
    
    rules = { Employee::WAREHOUSE => [ Employee::WAREHOUSE, Employee::REQUESTING, Employee::PURCHASING],
              Employee::WAREHOUSE_ADMIN => [ Employee::REQUESTING, Employee::ADMIN ],
              Employee::REQUESTING_ADMIN => [ Employee::WAREHOUSE, Employee::ADMIN ] }
    rules.each do |editor_role, subject_roles|
      subject_roles.each do |subject_role|
        editor = Employee.new(:role => editor_role)
        subject = Employee.new(:role => subject_role)
        editor.edit_profile?(subject).should == false
      end
    end
  end
  
  it "should be able to edit another person's login information only if he can edit the profile OR he is that person" do
    rules = { Employee::ADMIN => [ Employee::WAREHOUSE, Employee::REQUESTING, Employee::PURCHASING],
              Employee::WAREHOUSE => [ Employee::WAREHOUSE, Employee::REQUESTING, Employee::PURCHASING],
              Employee::WAREHOUSE_ADMIN => [ Employee::WAREHOUSE, Employee::WAREHOUSE_ADMIN, Employee::REQUESTING ],
              Employee::REQUESTING_ADMIN => [ Employee::REQUESTING, Employee::REQUESTING_ADMIN, Employee::WAREHOUSE ] }
    rules.each do |editor_role, subject_roles|
      subject_roles.each do |subject_role|
        editor = Employee.new(:role => editor_role)
        subject = Employee.new(:role => subject_role)
        if !editor.edit_profile?(subject)
          subject = editor
          editor.edit_login?(subject).should == true
        end
      end
    end
  end
  
  it "should only be a profile admin if the user is an admin" do
    [Employee::WAREHOUSE, Employee::PLANNING, Employee::PURCHASING].each do |role|
      Employee.new(:role => role).should_not be_profile_admin
    end
    
    [Employee::ADMIN, Employee::WAREHOUSE_ADMIN, Employee::REQUESTING_ADMIN].each do |role|
      Employee.new(:role => role).should be_profile_admin
    end
  end

  it "should list out all employees for a select_tage" do
    employees = Employee.list_employees
    employees.should == Employee.find(:all, :order => "last_name").map { |e| [e.full_name, e.id]}.unshift([nil, nil])
    
    employees = Employee.list_employees(:name => true)
    employees.should == Employee.find(:all, :order => "last_name").map { |e| [e.full_name, e.short_name]}.unshift([nil, nil])
    
    employees = Employee.list_employees(:default => "The Whos")
    employees.should == Employee.find(:all, :order => "last_name").map { |e| [e.full_name, e.id]}.unshift(["The Whos", nil])
  end
  
  it "should list out all employee names for autocomplete using a search query" do
    employee = new_employee(:first_name => "supercalifragilicious", :last_name => "a")
    employee.save
    
    employee_2 = new_employee(:first_name => "supercalifragilicious", :last_name => "b")
    employee_2.save
    
    employee.should be_valid; employee_2.should be_valid
    
    Employee.list_employee_names("supercalifragilicious").should == [employee.entire_full_name, employee_2.entire_full_name]
    Employee.list_employee_names("supercalifragilicious", true).should == [employee.entire_name_with_id, employee_2.entire_name_with_id]
  end
end
