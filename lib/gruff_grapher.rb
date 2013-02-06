module GruffGrapher
    
    def generate_gruff_pdf
        graph_gruff
        @pdf = PDF::Writer.new(:orientation => :portrait, :justification => :left)
        @pdf.add_image @image_g, 50, 400
        @pdf.add_image @image_p, 50, 50
    end
    
    def graph_gruff
        # Grabs the report info selected by the user
        report = params[:report]
        # Sets the y-axis label
        @y_label = "$"
        # Format for the x-axis labels
        @time_format = "%b-%d"
        
        # Instantiates the array for column labels
        @labels = {}
        
        graph_type = "bar" # or "line"
        
        # Size of graphs
        size = "500x300"
        
        # Creates the Gruff Bar or Line Graph based on 'type'
        if graph_type == "bar"  
            @g = new_graph(graph_type, size)
            @p = new_graph(graph_type, size)
        elsif graph_type == "line"
            @g = new_graph(graph_type, size)
        end
        
        # Report for this week
        if report =~ /this-week/ 
            setup_week_cumulative_money_graph 
        # Report for this month grouped by week
        elsif report =~ /this-month-by-week/ 
            setup_month_by_week_cumulative_money_graph
        # Report for this month grouped by day
        elsif report =~ /this-month-by-day/ 
            setup_month_by_day_cumulative_money_graph
        end
               
        
        get_order_data
        setup_graph
        #debugger
        @image_g = @g.to_blob('JPG')
        @image_p = @p.to_blob('JPG')
    end
  
     # Initializes a new Gruff graph based on the graph_type and size passed in.
    def new_graph(graph_type, size)
        # Dynamically creates a new chart of graph_type
        g = Gruff.const_get(graph_type.camelcase).new(size)
        return g
    end  
  
    def setup_week_cumulative_money_graph
         # Sets the end date (usually today)
        today = Date.today
        @start_date = (today-7)
        @end_date = today
        @g.title = "PO's This Week"
        @p.title = "PO's This Week"
        @g_data_title = "Dollars Spent - Cumulative"
        @p_data_title = "PO's Generated - Cumulative"
        begin_date = @start_date
        # Calculate the dates for each column and store them into labels{}
        i = 0
        while begin_date < @end_date do
            @labels[i] = begin_date
            begin_date = begin_date + 1.day
            i += 1            
        end
        # X-axis label
        @g.x_axis_label = "Week of #{@start_date.strftime('%m/%d/%Y')}"
    end
  
    def setup_month_by_week_cumulative_money_graph
         # Sets the end date (usually today)
        today = Date.today
        @start_date = (today-50)
        @end_date = today
        @g.title = "PO's This Month"
        @g_data_title = "Dollars Spent - Cumulative"
        @p.title = "PO's This Month"
        @p_data_title = "PO's Generated - Cumulative"
        day = @start_date.wday # Finds which day of the week start_date is
        begin_date = day == 1 ? @start_date : @start_date - (day-1).days
        @g.x_axis_label = "Month starting #{@start_date.strftime('%m/%d/%Y')}"
          
        i = 0
        while begin_date < @end_date do
          @labels[i] = begin_date
          begin_date = begin_date + 1.week           
          i += 1            
        end
    end
    
    def setup_month_by_day_cumulative_money_graph
          # Sets the end date (usually today)
        today = Date.today
        @start_date = (today-30)
        @end_date = today
        @g.title = "PO's This Month"
        @g_data_title = "Dollars Spent - Cumulative"
        @p.title = "PO's This Month"
        @p_data_title = "PO's Generated - Cumulative"
        begin_date = @start_date
        # Calculate the dates for each column and store them into labels{}
        @real_labels = {}
        i = 0
        
        while begin_date < @end_date do
            @labels[i] = begin_date
            begin_date = begin_date + 1.day
            if i % 7 == 0
                @real_labels[i] = begin_date
            end
            i += 1            
        end  
         
        # X-axis label
        @g.x_axis_label = "Week of #{@start_date.strftime('%m/%d/%Y')}"
    end
    
    def get_order_data
       # Sets up the MySQL query  
        select = "total_cost, created"
        conditions = "created <= '#{@end_date}' AND created >= '#{@start_date}'"
        @orders = Order.find(:all, :select => select, :conditions => conditions) 
    end
    
    def generate_data_array
        cost_hash = {}
        pos_hash = {}
        
        # Iterate through orders
        @orders.each do |order|
          # Iterate through the labels hash (each key is a date)
          @labels.each_key do |key|
            cost_hash[key] ||= 0
            pos_hash[key] ||= 0
            # Check if date of order is greater than date of label container
            if order.created >= @labels[key]
              # Check that the order was created in the dates between key and key+1    
              if (@labels.size == key && order.created >= @labels[key]) || (@labels[key+1] && order.created < @labels[key+1])
                cost_hash[key] += order.total_cost unless order.total_cost.blank?
                pos_hash[key] += 1 unless order.total_cost.blank?
              end
            end
          end
        end
        
        return cost_hash, pos_hash
    end
    
    def setup_graph
        # Grabs the data        
        cost_hash, pos_hash = generate_data_array
        
        @labels = @real_labels || @labels
        @g.labels = @labels
        @p.labels = @labels
       
        # Formats the date for the labels of each column, as specified by time_format
        @labels.each do |key, value|
          @g.labels[key] = value.strftime(@time_format)
          @p.labels[key] = value.strftime(@time_format)
        end
        
        
        
        # Sorts the array by the date
        cost_array = cost_hash.sort {|a,b| a[0] <=> b[0]}
        pos_array = pos_hash.sort {|a,b| a[0] <=> b[0]}
 
        # Assigns the companies to companies hash, jobs open to open_values, and total jobs to total_values
        g_data = []
        p_data = []
        max = 0
        cost_array.each_with_index do |value, index|
           max += value[1]
           g_data << max
        end
        
        max = 0
        pos_array.each_with_index do |value, index|
           max += value[1]
           p_data << max
        end
        
      
        
      
        
        # Uses the BP color scheme as defined in gruff_extender.rb
        @g.theme_bp
        @p.theme_bp
          @g.data(@g_data_title, g_data)
        @p.data(@p_data_title, p_data)
        @g.font = @p.font = File.expand_path('artwork/fonts/Vera.ttf', Rails.root) # Font selector
        
        # Modify this to represent your actual data models
        #g.maximum_value = rounding(max)
        @g.minimum_value = @p.minimum_value = 0
        #g.y_axis_increment = rounding(max * 0.10)
        
        
        @g.draw_text_on_image(320,30, "#{Date.today.strftime('%m/%d/%Y')}")
        @p.draw_text_on_image(320,30, "#{Date.today.strftime('%m/%d/%Y')}")
        @g.hide_legend = false
        @g.x_axis_label = @p.x_axis_label = @x_label
        @g.y_axis_label = @p.y_axis_label = @y_label
        
        bp_logo = "C:\\rails\\po_tracker\\public\\graphics\\bp-big.gif"
        
        @g.add_image(bp_logo, 20, 20, 40, 50)
        @p.add_image(bp_logo, 20, 20, 40, 50)
       
        @g.no_data_message = @p.no_data_message = "There is no cost data available for the range of dates you selected."
       
        @filename = "graph.png" 
    end
    
    
    def render_gruff_graph(params)
        
        params[:companies] ||= "-1"
        graph_type = params[:type] || "0"
        
        # Looks for the company selected. If none found, selects the first one.    
        if params[:id]
          @company = Company.find(params[:id]) # Find company from summary_of page.
        else
          @company = Company.find :first
        end
    
        units = params[:unit] ? params[:unit].split("/") : nil
        
        # Finds the total job info for @company
        jobs, completed_jobs, open_jobs, total_jobs = company_graph_data(@company.id)
        
        # Set canvas size in pixels
        size = '800x500'        
        
        # Create a new Gruff Graph
        @graph = new_graph(graph_type,size)
        
        # Use the BP theme colors.
        @graph.theme_bp
        
        # Select which kind of graph to render based on params[:type]
        case graph_type
        when "pie" then render_pie_graph(completed_jobs, open_jobs, total_jobs, @company.name)
        when "stacked_bar" then render_stacked_bar_graph(jobs,completed_jobs, open_jobs, total_jobs, @company.name)
        end
        
        # Adds the Vera font
        @graph.font = File.expand_path('artwork/fonts/Vera.ttf', Rails.root) # Font selector
      
    end
    
    
    # Adds data for a pie graph for the completed/open/total jobs summary.
    def render_pie_graph(completed_jobs,open_jobs,total_jobs,company_name)
        @graph.data("#{open_jobs.to_s} Open",[open_jobs])
        @graph.data("#{completed_jobs.to_s} Completed",[completed_jobs])
        @graph.title = "Open Jobs for #{company_name}"  
        # Sets the initial position        
        @graph.zero_degree = 180 
        add_date(320,-240, 17)
        add_logo       
    end
    
    # Adds data for a pie graph for the completed/open/total job-states summary.
    def render_stacked_bar_graph(jobs,completed_jobs,open_jobs,total_jobs,company_name)
        open_array = [open_jobs]
        completed_array = [completed_jobs]
        
        Job::JOB_STATE_TYPES.each do |state|
            open, completed = Job.get_state_jobs_for_graph(state, jobs, @company.id, "graph")
            open_array << open
            completed_array << completed
        end  
        
        @graph.data("Open",open_array)
        @graph.data("Completed",completed_array)
        
        @graph.title = "Open job states for #{company_name}"
    
        labels = {}
        %w( Total Fab NDE Demo Field Paint Insul).each_with_index do |name, index|
           labels[index] = name 
        end
        
        @graph.labels = labels
        
        #@graph.maximum_value = total_jobs.to_i
        @graph.minimum_value = 0
        add_date(320,7,17)
        add_logo
        
       if 1 >= (total_jobs.to_f * 0.10).to_i
           @graph.y_axis_increment = 1
       else
          @graph.y_axis_increment = (total_jobs.to_f * 0.10).to_i
       end
    end
    
    # Adds the BP Logo stored in public/graphics/bp-big.gif
    def add_logo
        bp_logo = "#{Rails.root}/public/graphics/bp-big.gif"
        x_pos = 20
        y_pos = 20
        # Resizes it to 60x80 pixels
        resize_x = 40
        resize_y = 50
        # Calls the custom method defined in module GruffExtender (lib/gruff_extender.rb)
        @graph.add_image(bp_logo, x_pos, y_pos, resize_x, resize_y)
    end
    
    # Adds the date to the graph
    def add_date(x_pos,y_pos,size)
        @graph.font_size(size)
        @graph.draw_text_on_image(x_pos,y_pos, "#{Date.today.strftime('%m/%d/%Y')}")
    end

    def company_graph_data(company_id,start_date=nil,end_date=nil,units=nil)
        jobs, completed_jobs, open_jobs, total_jobs = Job.get_company_jobs_for_graph(company_id, "graph", start_date, end_date, units)
    end
    
     def rounding(num)
      length = num.to_i.to_s.length    
      
      if length > 2
        extra = length - 2
        num = num.to_f
        num = num.round_to(-extra)
        num = num.to_i
      else
        num = num.to_f
        num = num.round_to(-1)
        num = num.to_i
      end
      num
    end
end

