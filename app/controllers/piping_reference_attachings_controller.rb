class PipingReferenceAttachingsController < SextController
	RESOURCE = PipingReferenceAttaching
  	# GET /piping_reference_attachings
  	def index
  		super
  	end

  	# GET /piping_reference_attachings/1
  	def show
  		super
  	end

  	# GET /piping_reference_attachings/new
  	def new
  		super
  	end

  	# GET /piping_reference_attachings/1/edit
  	def edit
    	super
  	end

  	# POST /piping_reference_attachings
  	def create
		super
  	end

  	# PUT /piping_reference_attachings/1
  	def update
    	super
  	end

	# DELETE /piping_reference_attachings/1
  	def destroy
    	super
  	end
  	
  	def create_with_piping_reference
  		@piping_reference = PipingReference.new
  		if @piping_reference.save_with_attaching(params)
  			json = { :success => true }
 		else
 			json = { :success => false, :errors => {} }
 			@piping_reference.errors.each { |key, val| json[:errors][key] = val }
		end
		
		# Must render text since the ExtJS form uses fileUpload = true.
		# This forces the submission to pass through an iFrame first,
		# causing all sorts of havoc with JSON:
		# http://extjs.com/deploy/ext-2.2.1/docs/?class=Ext.form.BasicForm
		render :text => json.to_json
 	end
  	  	
end
