class PipingReferencesController < SextController
	RESOURCE = PipingReference
	skip_before_filter :login_required, :only => [:view]
	skip_before_filter :is_popv_admin, :only => [:view]
	before_filter :login_or_access_key_required, :only => [:view]
	
	# Main gateway for grabbing PipingReferences from the server.
	def view
		@piping_reference = PipingReference.find(params[:id])
		send_file @piping_reference.path, {
			:filename => @piping_reference.filename, 
			:type => @piping_reference.content_type
			# Can be used if lighttpd or Apache
			# have been configured for X-Sendfile:
			# :x_sendfile => true 			
		}
	end
	
  	# GET /piping_references
  	# GET /piping_references.xml
  	def index
  		super
  	end

  	# GET /piping_references/1
  	# GET /piping_references/1.xml
  	def show
  		super
  	end

  	# GET /piping_references/new
  	# GET /piping_references/new.xml
  	def new
  		super
  	end

  	# GET /piping_references/1/edit
  	def edit
    	super
  	end

  	# POST /piping_references
  	# POST /piping_references.xml
  	def create
		super
  	end

  	# PUT /piping_references/1
  	# PUT /piping_references/1.xml
  	def update
    	super
  	end

	# DELETE /piping_references/1
  	# DELETE /piping_references/1.xml
  	def destroy
    	super
  	end
  	
  	
  	private
  	
  	  # Allows for validation based on a Vendor-specific access key
  	def login_or_access_key_required
  		unless access_key_found? || verify_login
    	  redirect_to '/404' and return false
    	end
  	end

end
