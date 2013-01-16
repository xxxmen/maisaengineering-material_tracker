class SextController < ApplicationController
  DEFAULT_LIMIT = 40
  DEFAULT_START = 0

  #anyone can index or show the popv items
  before_filter :is_popv_admin, :except => [:index, :show, :tabs, :save_tabs, :store]


  def tabs
  	current_tabs = Employee.current_employee.current_popv_tabs
  	if(current_tabs.blank?)
  		current_tabs = "[]"
  	end
  	@json = {:success => true, :record => current_tabs}

  	render :text => @json.to_json
  end

  def save_tabs
  	puts "TABS: #{params[:tabs]}}"
  	if(params[:tabs])

  		Employee.current_employee.current_popv_tabs = params[:tabs]
  		Employee.current_employee.save

  		@json = {:success => true, :record => Employee.current_employee.current_popv_tabs}
  	else
  		@json = {:success => false}
  	end
  	render :text => @json.to_json
  end

  # lists out records
  # for searching, pass in params[:query]
  # for filtering, pass in params[:filter] = {attributes}
  def index(should_render=true)
    if(params[:controller] == 'sext') && (!params[:resource]) && (params[:action] == 'index')
      render :action => 'index' and return
    end

    limit = params[:limit] || DEFAULT_LIMIT
    start = params[:start] || DEFAULT_START
    if params[:sort]
      sort = params[:sort].include?(".") ? params[:sort] : klass.table_name + "." + params[:sort]
    else
      sort = klass.table_name + ".id"
    end

    const_order_mapping = klass.const_defined?("PAGE_ORDER_MAPPING") ? klass::PAGE_ORDER_MAPPING : {}
    dir = params[:dir] || "ASC"
    order = sort + " " + dir

    if(!params[:sort].blank?)
      if const_order_mapping.has_key?(params[:sort].to_sym)
        order = const_order_mapping[params[:sort].to_sym] + " " + dir
      end
 	  end
    order = klass.table_name + "." + order if !order.include?(".")

    if params[:order]
      order = params[:order]
    end

    filters = params[:filter].blank? ? nil : params.dup
    search_conditions = build_search(params[:query], filters, params[:additional_conditions])

    select = klass.const_defined?("SEXT_SELECT_FIELDS") ? klass::SEXT_SELECT_FIELDS : nil

    if(params[:all])
      records = klass.find(:all, :select => select, :order => order, :conditions => search_conditions)
    elsif(params[:all_index])
      records = klass.find(:all, :order => order, :include => Sext.get_joins(klass), :conditions => search_conditions)
    else
      records = klass.find(:all, :limit => limit, :offset => start, :order => order, :include => Sext.get_joins(klass), :conditions => search_conditions)
    end

    @records = records

    records = Sext.get_data(records,true, params)

    record_count = 0
    klass.send(:with_scope, :find => { :conditions => search_conditions, :include => Sext.get_joins(klass)}) do
      record_count = klass.count
    end
    @record_count = record_count

    @json = { :records => records, :count => record_count }
    render_if should_render, :text => @json.to_json
  end

  def create(should_render=true)
    @record = klass.new
    save_and_render
  end

  def show(should_render=true)
  	record = klass.find_by_id(params[:id])
  	records = []
  	if(!record.blank?)
  		record = Sext.get_data([record])[0]
  		record_count = 1
  	end

  	@json = { :data => record, :success => true }
    render_if should_render, :text => @json.to_json
  end
  def update(should_render=true)
    @record = klass.find(params[:id])
    save_and_render
  end

  def csv_export
  	require 'csv'

  	related_names = params[:related_values] ? true : false

  	our_columns = klass.columns.dup
  	title_columns = our_columns.delete_if{ |c| c.type == :binary  }

  	#Our related values are STRICTLY based on belongs_to relations.
  	#if none exist, we have no related names
  	my_associations = klass.reflect_on_all_associations(:belongs_to)
  	if(my_associations.size <= 0)
  		related_names = false
  	end

  	if(related_names == false)
  		column_headers = title_columns.map(&:name)
  	else
  		column_headers = title_columns.map { |c|
  			if(c.name =~ /_id$/)
  				this_association = nil
  				my_associations.each do |our_association|
  					if(our_association.primary_key_name == c.name)
  						this_association = our_association
  					end
  				end
  				if(!this_association.nil?)
  					c.name[0,c.name.length - 3] + '_' + Sext.associated_column_nice_name(this_association.name.to_s.camelcase)
  				else
  					c.name
  				end
  			else
  				c.name
  			end
  		}
  	end
  	records = klass.find(:all)
  	report = StringIO.new

      CSV::Writer.generate(report, ',', "\r\n") do |title|
        title << column_headers
    	records.each do |r|
    		data = []
    		title_columns.each do |column|
    			this_data = r[column.name]
    			if(related_names == true)
    				if(column.name =~ /_id$/)
		  				this_association = nil
		  				my_associations.each do |our_association|
		  					if(our_association.primary_key_name == column.name)
		  						this_association = our_association
		  					end
		  				end
		  				if(!this_association.nil?)
		  					this_fieldname = Sext.associated_column_nice_name(this_association.name.to_s.camelcase)
		  					if(this_fieldname != 'id')
		  						this_record = this_association.klass.find(r[column.name]) rescue this_record = nil
		  						if(!this_record.nil?)
			  						this_data = this_record[this_fieldname]
		  						end
  							end
	  					end
  					end
    			end
    			data << this_data
    		end
          title << data
        end
      end
     report.rewind
     send_data(report.read,:type=>'text/csv;charset=iso-8859-1;header=present',
     						:filename=>"#{klass.name.pluralize}.csv",
     						:disposition =>'attachment',
     						:encoding => 'utf8')


  end


 def csv_import
 	require 'csv'

    @parsed_file=CSV::Reader.parse(params[:file_upload])

    @parsed_file = @parsed_file.to_a
    header_fields = @parsed_file.shift



    #array of records we're creating.
    #for now, we hold these in memory.  not good for large data sets
    records = []

    all_related = klass.reflect_on_all_associations(:belongs_to)

    #parsed_file will be left with just the data for each row
    #go through all the rows, try and create a "new" record.  check if it's valid also.
    #if there are any errors, we need to return them and save NONE of the items.
    @parsed_file.each_with_index  do |row, row_index|
	    record = klass.new
		row.each_with_index do |row_field_data, row_field_index|
			next if(header_fields[row_field_index] == 'id')
    		record.send(header_fields[row_field_index] + '=', row_field_data.to_s)
		end

		if(!record.valid?)
			these_errors = []
			record.errors.each {|attr, msg| these_errors << "#{attr}: '#{record.send(attr)}' : '#{msg}'"}
			raise "Row #{row_index + 1} is NOT valid: #{these_errors.join(', ')}"
		end

		#add this valid record to our list
		records << record

	    GC.start if row_index%50==0
	end

 	#go throught the records we've created and save them.
 	records.each do |record|
 		record.save!
 	end

 	render :text => {:success => true}.to_json

 	rescue => e
 		render :text => {:success => false, :errors => e.message}.to_json
 end

  def store(should_render=true)
    display_field = params[:id]
    params[:all] = "true"
    records = klass.find(:all, :order => display_field)
    records = Sext.get_data(records, false, params)
    @json = { :records => records, :count => klass.count }
    render_if should_render, :text => @json.to_json
  end


  # for habtm relationships, adding them
  def add(should_render=true)
    habtm_association(should_render) do |association|
      @primary_record.send(association.name) << @foreign_record unless @primary_record.send(association.name).include?(@foreign_record)
    end
  end

  # for habtm relationships, removing them
  def remove(should_render=true)
    habtm_association(should_render) do |association|
      @primary_record.send(association.name).delete(@foreign_record) if @primary_record.send(association.name).include?(@foreign_record)
    end
  end
  def habtm_association(should_render=true)
    association = klass.reflect_on_association(params[:id].to_sym)

    klass_id = association.primary_key_name.to_sym
    foreign_id = association.association_foreign_key.to_sym
    foreign_klass = Module.const_get(association.class_name)

    @primary_record = klass.find(params[klass_id])
    @foreign_record = foreign_klass.find(params[foreign_id])

    yield association

    @json = { :success => true}
    render_if should_render, :text => @json.to_json
  end

  # deletes
  def destroy(should_render=true)
    @record = klass.find(params[:id])
    @record.destroy
    @json = {:success => true}
    render_if should_render, :text => @json.to_json
  end

  protected

  def authorized?
    true
  end

  def get_const(name)
  		return Module.const_get(name)
  	rescue
  		return nil
  end
  def klass
  	controller = get_const((params[:controller] + '_controller').camelcase)

  	if(controller) && controller.constants.include?('RESOURCE')
  	 	resource = controller::RESOURCE
  	 else
  	 	resource = Module.const_get(params[:resource].singularize.camelcase)
  	 end

  	 @klass ||= resource || (raise NotImplementedError, "#{self.class} does not define a RESOURCE"; nil)
  end

  def save_and_render(should_render=true)
    attributes = {}
    params.each do |key, value|
      next if key == "id" || key == "action" || key == "controller"
      if(@record.class.columns.detect { |c| c.name == key }.class == :binary)
      	data = value
		unless data.blank?
			data.rewind
			attributes[key] = data.read unless data.size == 0
		end
	  else
	  	attributes[key] = value if @record.respond_to?(key + "=")
  	  end
    end

    @record.attributes = attributes
    @record.save!
    @json = {:success => true, :record => @record.sext_data}
    render_if should_render, :text => @json.to_json and return
  rescue ActiveRecord::RecordInvalid
    @json = {:success => false, :errors => {}}
    @record.errors.each { |key, val| @json[:errors][key] = val }
    render_if should_render, :text => @json.to_json and return
  end

  def render_if(should_render, *args)
    if should_render
      render *args
    end
  end


  #MAGIC FOR RECORD FILTERS
  def build_search(query, filters, additional_where_clauses='')
    if query.blank? && filters.blank? && additional_where_clauses.blank?
      return nil
    end

    # get all available search fields
    search_fields = klass.columns.dup.find_all { |c| c.type == :boolean || c.type == :string || c.type == :text }.map { |c| klass.table_name + "." + c.name }
    if klass.const_defined?("SEXT_SEARCH_FIELDS")
      search_fields = klass::SEXT_SEARCH_FIELDS.map { |field| field.include?(".") ? field : klass.table_name + "." + field }
    end

    search_conditions = []
    search_args = []
    # build out conditions using the query
    unless query.blank?
      search_fields.each do |field|
        search_conditions << "#{field} LIKE ?"
        search_args << "%" + query + "%"
      end
    end

    filter_conditions = []
    filter_args = []
    # build out conditions using the filters
    unless filters.blank?

      # treat regular columns, search fields, and date fields all differently when searching
      columns = klass.columns.dup.map { |c| c.name.to_s }
      bool_fields = klass.columns.dup.delete_if { |c| c.type != :boolean }.map { |c| c.name.to_s }
      date_fields = klass.columns.dup.delete_if { |c| c.type != :date }.map { |c| c.name.to_s }
      string_fields = klass.columns.dup.find_all { |c| c.type == :string || c.type == :text }.map { |c| c.name.to_s }
      search_columns = {}
      if(klass.const_defined?("PAGE_ORDER_MAPPING"))
        search_columns = klass::PAGE_ORDER_MAPPING
      end

      # go through all filters and build the conditions
      filters.each do |field, value|
        next if value.blank?

        if string_fields.include?(field.to_s)
          # do a like comparison for string/text fields
          filter_conditions.push("#{klass.table_name}.#{field} LIKE ?")
          filter_args.push('%' + value + '%')
       elsif search_columns.include?(field.to_sym)

         #use the value from the search field for the column we're mapping.
         #we probably need to include those tables also....
         filter_conditions.push("#{search_columns[field.to_sym]} LIKE ?")
         filter_args.push('%' + value + '%')
       elsif date_fields.include?(field.to_s) && value.to_s =~ /\d+\/\d+\/\d\d\d\d/
          # change to MySQL date format for date fields and maybe search for date ranges
          end_date_field = field.to_s + '_end_range'
          end_date = filters[end_date_field] || filters[end_date_field.to_sym]
          if end_date.blank?
            filter_conditions.push("#{klass.table_name}.#{field} = ?")
            filter_args.push(value.to_date.to_s)
          else
            filter_conditions.push("#{klass.table_name}.#{field} >= ?")
            filter_conditions.push("#{klass.table_name}.#{field} <= ?")
            filter_args.push(value.to_date.to_s)
            filter_args.push(end_date.to_date.to_s)
          end
        elsif bool_fields.include?(field.to_s)

          filter_bool_field = field.to_s #+ '_filter'
          filter_bool = filters[filter_bool_field] || filters[filter_bool_field.to_sym]
          if filter_bool == "Yes"
            filter_conditions.push("#{klass.table_name}.#{field} = ?")
            filter_args.push(true)
          elsif filter_bool == "No"
            filter_conditions.push("(#{klass.table_name}.#{field} = ? OR #{klass.table_name}.#{field} IS NULL)")
            filter_args.push(false)
          end
        elsif(columns.include?(field.to_s))
          # otherwise do a straight == comparison
          filter_conditions.push("#{klass.table_name}.#{field} = ?")
          filter_args.push(value)
        end
      end
    end

    search_conditions =  search_conditions.join(" OR ")
    if(!search_conditions.blank?)
    	search_conditions = "(" + search_conditions + ")"
    end

    filter_conditions = filter_conditions.join(" AND ")
    if !search_conditions.blank? && !filter_conditions.blank?
      conditions = search_conditions + " AND " + filter_conditions
    elsif search_conditions.blank?
      conditions = filter_conditions
    else
      conditions = search_conditions
    end

    if(!additional_where_clauses.blank?) && (!additional_where_clauses[0].blank?)
      if(conditions.blank?)
        conditions = additional_where_clauses[0]
      else
        conditions = additional_where_clauses[0] + " AND " + conditions
      end

      if(!additional_where_clauses[1].blank?)
        filter_args = additional_where_clauses[1] + filter_args
      end

    end
    return [conditions, *(search_args + filter_args)]
  end
end
