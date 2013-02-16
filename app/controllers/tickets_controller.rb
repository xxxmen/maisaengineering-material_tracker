class TicketsController < ApplicationController
	
	############################################################################
	# SETUP
	
	layout 'tickets'

	############################################################################
	# FILTERS
	
	before_filter :is_popv_admin, :only => [:edit, :update, :destroy]
	
	############################################################################
	# ACTIONS
	
		
  # GET /tickets
  # GET /tickets.xml
  def index

    Ticket.filter(params, current_employee) do
      @tickets = Ticket.list_all(params, :order => "tickets.updated_at", :sort => 'DESC')
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tickets }
    end
  end


    def search
        flash[:previous_filter_query] = params[:q]
        do_search
        if @tickets.size == 0
          flash[:error] = "There were no search results for <span style='color: red;'>'#{params[:q]}'</span>".html_safe
          redirect_to tickets_path and return
        elsif @tickets.size == 1
          flash.now[:notice] = "Found 1 ticket"
        else
          flash.now[:notice] = "<div id='result_msg'>Found #{@tickets.count} results for <span style='color: orangered;'>'#{params[:q]}'</span>
          <a href='#' onclick=\"$('refine').toggle(); $('refine').down('input').focus(); $('result_msg').hide(); \">Filter Results</a></div>".html_safe
        end        
        render :action => :index
    end


  # GET /tickets/1
  # GET /tickets/1.xml
  def show
    @ticket = Ticket.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ticket }
    end
  end

  # GET /tickets/new
  # GET /tickets/new.xml
  def new
    @ticket = Ticket.new
    
    if params[:referral]
    	@ticket.check_referral(params[:referral])
   	end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ticket }
    end
  end

  # GET /tickets/1/edit
  def edit
    @ticket = Ticket.find(params[:id])
  end

  # POST /tickets
  # POST /tickets.xml
  def create
    @ticket = Ticket.new(params[:ticket])
    
    respond_to do |format|
      if @ticket.save
        flash[:notice] = 'Ticket was successfully created.'
        format.html { redirect_to(@ticket) }
        format.xml  { render :xml => @ticket, :status => :created, :location => @ticket }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ticket.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tickets/1
  # PUT /tickets/1.xml
  def update
    @ticket = Ticket.find(params[:id])

    respond_to do |format|
      if @ticket.update_attributes(params[:ticket])
        flash[:notice] = 'Ticket was successfully updated.'
        format.html { redirect_to(@ticket) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ticket.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tickets/1
  # DELETE /tickets/1.xml
  def destroy
    @ticket = Ticket.find(params[:id])
    @ticket.destroy

    respond_to do |format|
      format.html { redirect_to(tickets_url) }
      format.xml  { head :ok }
    end
  end
  
  	def attachment
  		@ticket = Ticket.find(params[:id])
  		if @ticket.attachment?
  			send_file @ticket.attachment.path, :filename => @ticket.attachment_file_name
 		else
 			flash[:error] = "Sorry, an attachment for this ticket was not found."
 			redirect_to ticket_path(:id => params[:id])
		end
 	end
  	############################################################################
	private
	
	def do_search
        @tickets = Ticket.search_for(params)
    end
    
    def authorized?
    	true
   	end
end
