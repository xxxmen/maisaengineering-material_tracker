class ReferenceNumberTypesController < ApplicationController
	layout 'scaffold'
	skip_before_filter :login_required, :only => [:index]
	before_filter :admin_required, :except => [:index]
	
	def index
		@types = ReferenceNumberType.find(:all, :order => 'order_number ASC')
		respond_to do |format|
			format.html { render :index }
			format.json { 
				records = @types.map {|t| t.sext_data }
				json = { :succes => true, :count => @types.size, :records => records }
				render :json => json
			}
		end
	end
	

  # GET /types/1
  # GET /types/1.xml
  def show
    @type = ReferenceNumberType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @type }
    end
  end

  # GET /types/new
  # GET /types/new.xml
  def new
    @type = ReferenceNumberType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @type }
    end
  end

  # GET /types/1/edit
  def edit
    @type = ReferenceNumberType.find(params[:id])
  end

  # POST /types
  # POST /types.xml
  def create
    @type = ReferenceNumberType.new(params[:reference_number_type])

    respond_to do |format|
      if @type.save
        flash[:notice] = 'ReferenceNumberType was successfully created.'
        format.html { redirect_to reference_number_types_url }
        format.xml  { render :xml => @type, :status => :created, :location => @type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /types/1
  # PUT /types/1.xml
  def update
    @type = ReferenceNumberType.find(params[:id])

    respond_to do |format|
      if @type.update_attributes(params[:reference_number_type])
        flash[:notice] = 'ReferenceNumberType was successfully updated.'
        format.html { redirect_to reference_number_types_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /types/1
  # DELETE /types/1.xml
  def destroy
    @type = ReferenceNumberType.find(params[:id])
    @type.destroy

    flash[:notice] = "Deleted Reference Number Type: #{@type.name}"

    respond_to do |format|
      format.html { redirect_to(reference_number_types_url) }
      format.xml  { head :ok }
    end
  end
  
  ##############################################################################
  private
  
  def admin_required
  	unless current_employee.admin?
	  	flash[:error] = "You are not authorized to view this page."
  		redirect_to(:controller => "home", :action => "menu")
 	end
  end
	
end
