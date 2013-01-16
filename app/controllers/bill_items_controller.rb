class BillItemsController < SextController
    RESOURCE = BillItem   
    before_filter :is_popv_admin, :except => [:index, :show, :create, :create_many]
  
  def is_popv_admin
  	#popv admin can do anything
  	if(current_employee.popv_admin?)
  		return true
  	end
  	if(params[:id])
  		bill_item = BillItem.find(params[:id])
  		if(bill_item.bill.blank?)
  			return false
  		else
  			bill = bill_item.bill
  		end
  		#we're allowed to edit/Delete/update our own bills only
  		if(bill.employee.id == current_employee.id)
  			return true
  		else
  			return false
  		end
  	else
  		return true
  	end
  end
 
  # Creates multiple BOM items at once.
  def create_many
	records = ActiveSupport::JSON.decode(params[:records])
	records.each do |record|
  		BillItem.create(record)
  	end
  	render :json => {:success => true}.to_json 
  rescue
  	render :json => {:success => false}.to_json 
  end

#  def create
#    @bill = Bill.find(params[:bill_id])
#    @bill_item = @bill.bill_items.build(params[:bill_item])
#    @bill_item.manual = true
#    @bill_item.save!
#    render :nothing => true
#  rescue ActiveRecord::RecordInvalid
#    @bill_item.valid?
#    render :text => @bill_item.errors.full_messages.join("\n"), #:status => 500
#  end
#  
#  def create_pipe
#    @bill = Bill.find_by_id(params[:id]) || #current_employee.bills.create!
#    @bill_item = BillItem.find_by_id(params[:piping_update]) || #@bill.bill_items.build
#    @new_record = @bill_item.new_record?
#    @bill_item.manual = false
#    @bill_item.quantity = params[:piping_quantity]
#    @bill_item.unit_of_measure = "EA"
#    
#    
#    @bill_item.piping_class_detail_id = params[:piping_class_detail]
#    @bill_item.piping_subcomp_id = params[:piping_subcomponent] #unless params[:piping_subcomponent].blank?
#    @bill_item.size_1 = params[:piping_size_1] unless #params[:piping_size_1].blank?
#    @bill_item.size_2 = params[:piping_size_2] unless #params[:piping_size_2].blank?
#    @bill_item.save!
#    render :update do |page|
#      if @new_record
#        page << "window.location='/bills/#{@bill.id}/edit';"
#      else
#        @bill_item.reload
#        page << #"$('#{@bill_item.id}').down('td.description').update('#{@bill_item.di#splay}'.escapeHTML());"
#        page << #"$('#{@bill_item.id}').down('td.quantity').update('#{@bill_item.quant#ity}'.escapeHTML());"
#      end
#    end
#  rescue ActiveRecord::RecordInvalid
#    @bill_item.valid?
#    render :text => @bill_item.errors.full_messages.join("\n"), #:status => 500
#  end
#  
#  def show
#    @bill_item = BillItem.find(params[:id])
#    render :text => @bill_item.to_json, :content_type => #"text/javascript"
#  end
#  
#  def update
#    @bill_item = BillItem.find(params[:id])
#    @bill_item.update_attributes!(params[:bill_item])
#    render :nothing => true
#  rescue ActiveRecord::RecordInvalid
#    @bill_item.valid?
#    render :text => @bill_item.errors.full_messages.join("\n"), #:status => 500
#  end
#  
#  def destroy
#    @bill_item = BillItem.find(params[:id])
#    if @bill_item.bill.bill_items.size == 1
#      flash[:error] = "Could not delete the last line item, at least #one line item must exist"
#    else
#      @bill_item.destroy
#    end
#    render :nothing => true
#  end
end
