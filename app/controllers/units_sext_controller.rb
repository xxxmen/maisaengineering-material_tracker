class UnitsSextController < SextController
    RESOURCE = Unit
     
    def index
        # Sets the order to pass to SextController#index
        params[:order] = "ordered_number ASC, description ASC"
    
        # Calls SextController#index
        super(false)

        records = Sext.get_data(@records, true, {})
    
        @json = {:success => true, :records => records, :count => @record_count }
        render :text => @json.to_json
    end
 
end
