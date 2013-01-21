
class BulkChangesController < ApplicationController
  #before_filter :is_popv_admin
  def tables
    output = []
    #this is a list of our models

    output << {:table => 'piping_classes',  :table_name => 'Piping Classes'}
    output << {:table => 'piping_class_details',  :table_name => 'Piping Class Details'}
    output << {:table => 'valves',  :table_name => 'Valves'}
    output << {:table => 'piping_notes',  :table_name => 'Piping Notes'}
#    output << {:table => 'piping_references',  :table_name => 'References'}
    #output << {:table => 'piping_subcomponents',  :table_name => 'Sub Components'}
  #  output << {:table => 'piping_components',  :table_name => 'Piping Components'}


    @json = { :records => output, :count => output.length }
    render :text => @json.to_json
  end
  def fields
    output = []
    table_name = params[:table]
    this_model = table_name.classify.constantize
    search_fields = this_model.columns.dup#.find_all { |c| c.type == :string || c.type == :text }
    search_fields.each do |field|
        output << {:field => field.name, :field_name => field.name}
    end
    @json = { :records => output, :count => output.length }
    render :text => @json.to_json
  end
  def search_results
    output = []
    output = generate_results_from_search_criteria(params[:table],params[:search_criteria])

    @json = { :records => output, :count => output.length }
    render :text => @json.to_json
  end

  def generate_results_from_search_criteria(table_name, search_criteria_raw)
    table_name = table_name
    search_criteria_input = search_criteria_raw
    search_criteria_items = ActiveSupport::JSON.decode(search_criteria_input)
    conditions = [''];
    search_criteria_items.each do |criteria|
        conditions[0] += ' ' + criteria["field_name"] + ' '
        conditions[0] += criteria["compare_type"] + " ? AND"
        conditions << criteria["search_value"]
    end

    #trim the ' AND' from the end
    if(search_criteria_items.length > 0)
        conditions[0] = conditions[0][0..(conditions[0].length - 5)]
    end

    this_model = table_name.classify.constantize
    this_model.find(:all, :conditions => conditions)
    end

  def replace_results
    replace_field = params[:replace_field]
    replace_search_value = params[:replace_search_value]
    replace_new_value = params[:replace_new_value]

    search_result = generate_results_from_search_criteria(params[:table],params[:search_criteria])
    output = []
    search_result.each do |result|

        replacing_val=result[replace_field]
        if(replacing_val.blank?)
            replacing_val = ''
        end
        if(replacing_val.include?(replace_search_value))
            result[replace_field] = replacing_val.gsub(replace_search_value, replace_new_value)
            output << result
        end
    end

    @json = { :records => output, :count => output.length }
    render :text => @json.to_json
  end

  def finalize_replace
   require 'tempfile'
    begin
        RecordChangelog.enable_recording = false
        search_result = []
        output = []

        replace_field = params[:replace_field]
        replace_search_value = params[:replace_search_value]
        replace_new_value = params[:replace_new_value]

        search_result = generate_results_from_search_criteria(params[:table],params[:search_criteria])
        search_description = "Table: #{params[:table]}\r\nReplace Field: #{replace_field}\r\nReplace Search Value: #{replace_search_value}\r\nReplace New Value: #{replace_new_value}\r\nSearch Criteria: #{ActiveSupport::JSON.decode(params[:search_criteria])}"
        #create a new RecordChangelog object now
        rc = RecordChangelog.create(:record_type => "Bulk Change",
                                  :record_identifier => search_description,
                                  :action => "Bulk Replaced",
                                  :modified_at => Time.now)


        matched_results = []
        search_result.each do |result|
            replacing_val=result[replace_field]
            if(replacing_val.blank?)
                replacing_val = ''
            end
            if(replacing_val.include?(replace_search_value))
                matched_results << result
            end
        end

        #save the match
        tf = Tempfile.new('')
        CsvFu.write_file(tf.path, matched_results.to_csv)
        rc.attachment = tf
        rc.save!
        
        search_result.each do |result|
            replacing_val=result[replace_field]
            if(replacing_val.blank?)
                replacing_val = ''
            end
            if(replacing_val.include?(replace_search_value))
                result[replace_field] = replacing_val.gsub(replace_search_value, replace_new_value)
                result.save!
            end
        end

        RecordChangelog.enable_recording = false
      @json = { :success => true, :errors => "Success: Replaced " + matched_results.length.to_s + " records!" }
      render :text => @json.to_json
    rescue => e
        debugger
        @json = { :success => false, :errors => e.to_s }
        render :text => @json.to_json
    end
  end
end
