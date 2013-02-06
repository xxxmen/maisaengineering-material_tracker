class RemoteClientController < ApplicationController
  before_filter :login_required, :only => :index
  
  CLIENT_TABLES = [Order, Vendor, Unit, Employee, Company, OrderedLineItem, PoStatus, InventoryItem] # TODO we'll need to relate clients
  def get_schema
    schema = CLIENT_TABLES.map {|t| {:name => t.table_name, :columns => table_schema(t)} }
    
#    respond_to do |format|
#      format.js { render({:content_type => :js, :text => schema.to_json}) }
#    end
    
    render_json schema.to_json
  end
  
  def get_requests
  	default_group_id = Group.get_default_id
  	if default_group_id.present?
  		records = MaterialRequest.find(:all, :conditions => 
            ["acknowledged_by IS NULL AND drafted_by IS NULL AND group_id = ?", default_group_id], 
            :order => "id DESC", :limit => 10)
    else
        records = MaterialRequest.find(:all, :conditions => 
            ["acknowledged_by IS NULL AND drafted_by IS NULL"], 
            :order => "id DESC", :limit => 10)
    end
    render :json => "[" + records.map{ |m| m.get_json }.join(",") + "]"
  end
  
  def get_quotes
    render :json => "[" + Quote.find(:all, :conditions => "acknowledged_by IS NULL AND
            (SELECT COUNT(*) FROM quote_items WHERE quote_items.quote_id = quotes.id AND quote_items.price > 0.0) > 0", 
            :include => "quote_items", :order => "quotes.id DESC", :limit => 10).map{ |m| m.get_json }.join(",") + "]"
  end
  
  def merge_data
    # json = {type:ModelName, old_attr:{hash of attributes}, new_attr:{hash of attributes}}
    if request.post?
      data = ActiveSupport::JSON.decode(params[:json])
      klass = Object.const_get(data['type'].camelcase)
      if CLIENT_TABLES.include? klass
        res = klass.merge(data['old_attr'], data['new_attr'])
        render_json res.to_json
        return
      end
    end
    render_json "error".to_json    # TODO add error for bad table name
  end
  
  def set_last_connected
    File.open("#{Rails.root}/log/connection.log", "w") { |file| file.write Time.now.to_s(:db) }
    render :nothing => true
  end

  def get_last_connected
    time = File.open("#{Rails.root}/log/connection.log") { |file| file.read }
    render_json({:time => time}.to_json)
  end
  
  def get_order
    order = if params[:po_no]
      Order.find_by_po_no(params[:po_no])
    else
      Order.find_by_id(params[:id])
    end
    render_json(order.to_json)
  end
  
  def get_purchase_order_lines
    order = Order.find_by_po_no(params[:po_no])
    if order
      render_json order.ordered_line_items.to_json
    else
      render :text => "Purchase Order not found", :status => 404
    end
  end
  
  def get_material_request_lines
    request = MaterialRequest.find_by_tracking(params[:tracking])
    if request
      render_json request.items.to_json
    else
      render :text => "Material Request not found", :status => 404
    end
  end
  
  def delete_order
    order = if params[:po_no]
      Order.find_by_po_no(params[:po_no])
    else
      Order.find_by_id(params[:id])
    end
    
    if order
      order.destroy
      render_json(order.to_json)
    else
      render_json( { :error => "Could not find order" }.to_json )
    end
  end
  
  def get_version
    log_edit = LogEdit.find(:first, :order => "id DESC")
    if log_edit == nil
      render_json({ :ver => 0}.to_json)
    else
      render_json({ :ver => log_edit.id }.to_json)
    end
  end
  
  def update
    if params[:database_version]
      last_edit = LogEdit.find(:first, :order => "id DESC")
      if (last_edit and last_edit.id.to_i != params[:database_version].to_i)
        render_json({:error => 'Database Version Mismatch', :server_version => last_edit.id}.to_json)
        return
      end
    end
    # json = {type:ModelName, attr:{hash of attributes}}
    if request.post?
      data = ActiveSupport::JSON.decode(params[:json])
      klass = Object.const_get(data['type'].camelcase)
      if CLIENT_TABLES.include? klass
        res = klass.merge_update(data['attr'])
        render_json res.to_json
        return
      end
    end
    render_json "error".to_json    # TODO add error for bad table name    
  end
  
  # took out post request for testing purposes
  def create
    if params[:database_version]
      last_edit = LogEdit.find(:first, :order => "id DESC")
      if (last_edit and last_edit.id.to_i != params[:database_version].to_i)
        render_json({:error => 'Database Version Mismatch', :server_version => last_edit.id}.to_json)
        return
      end
    end
    # json = {type:ModelName, attr:{hash of attributes}}
    if request.post?
      data = ActiveSupport::JSON.decode(params[:json])
      klass = Object.const_get(data['type'].camelcase)
      if CLIENT_TABLES.include? klass
        res = klass.merge_create(data['attr'])
        render_json res.to_json
        return
      end
    end
    render_json "error".to_json    # TODO add error for bad table name    
  end
  
  def get_updates
    edits = LogEdit.find(
        :all, 
        # :conditions => ["id > ? AND loggable_type IN (?)", params[:id], CLIENT_TABLES.map {|t| t.name}.join(", ") ], 
        :conditions => ["id > ?", params[:id]],
        :order => "id",
        :limit => params[:limit] || 100)
    # TODO: clean up this call to build res
    res = {:ver => edits.map{|e|e.id}.max, 
           :data => edits.map {|e| {:name => e.loggable_type, :attr => (e.loggable ? e.loggable.attributes : nil)}}}

    render_json res.to_json
  end
  
  private
  def table_schema table
    column_specs = table.columns.map do |column|
      raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" if column.type.nil?
      spec = {}
      spec[:primay] = true if column.primary
      spec[:name] = column.name
      spec[:type] = column.type.to_s
      spec[:sql_type] = column.sql_type
      spec[:limit]= column.limit.inspect if column.type != :decimal
      spec[:precision] = column.precision.inspect if !column.precision.nil?
      spec[:scale] = column.scale.inspect if !column.scale.nil?
      spec[:null] = 'false' if !column.null
      spec[:default] = column.default if !column.default.nil?
      spec
    end.compact
    column_specs
  end
    
end
