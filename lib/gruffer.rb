module Gruffer
    def gfgraph_gruff
        # Grabs the report info selected by the user
        report = params[:report]
        # Sets the y-axis label
        y_label = "$"
        # Format for the x-axis labels
        time_format = "%b-%d"
        
        # Instantiates the array for column labels
        labels = {}
        
        # Sets the end date (usually today)
        today = Date.today
        
        # Report for this week
        if report =~ /this-week/ 
          start_date = (today-7)
          end_date = today
          title = "PO's This Week"
          data_title = "Dollars Spent - Cumulative"
          begin_date = start_date
          # Calculate the dates for each column and store them into labels{}
          i = 0
          while begin_date < end_date do
            labels[i] = begin_date
            begin_date = begin_date + 1.day
            i += 1            
          end
          
          # X-axis label
          x_label = "Week of #{start_date.strftime('%m/%d/%Y')}"
          
        # Report for this month
        elsif report =~ /this-month/ 
          start_date = (today-30)
          end_date = today
          title = "PO's This Month"
          data_title = "Dollars Spent - Cumulative"
          day = start_date.wday # Finds which day of the week start_date is
          begin_date = day == 1 ? start_date : start_date - (day-1).days
          x_label = "Month starting #{start_date.strftime('%m/%d/%Y')}"
          
          i = 0
          while begin_date < end_date do
            labels[i] = begin_date
            begin_date = begin_date + 1.week
            i += 1            
          end
        end
         
         # raise "#{labels.to_yaml} #{begin_date.to_s}"
        diff = (end_date - start_date).to_i
          
        # Sets up the MySQL query  
        select = "total_cost, created"
        conditions = "created <= '#{end_date}' AND created >= '#{start_date}'"
        @orders = Order.find(:all, :select => select, :conditions => conditions)
        
        
        gHash = {}
        gArray = []

        @orders.each do |order|
          labels.each_key do |key|
            gHash[key] ||= 0
            if order.created >= labels[key]
              if (labels.size == key && order.created >= labels[key]) || (labels[key+1] && order.created < labels[key+1])
                gHash[key] += order.total_cost unless order.total_cost.blank?
              end
            end
          end
        end
        
        #raise "#{gHash.to_yaml}"
        
        # Formats the date for the labels of each column, as specified by time_format
        labels.each do |key, value|
          labels[key] = value.strftime(time_format)
        end
        
        orders_array = gHash.sort {|a,b| a[0] <=> b[0]}
        
        # Assigns the companies to companies hash, jobs open to open_values, and total jobs to total_values
        data = []
        max = 0
        orders_array.each_with_index do |value, index|
           max += value[1]
           data << max
         end
    
        #raise "#{labels.to_yaml} \n #{data.join(",")} #{max.to_s} \n #{orders_array.join(",")}"

        type = "bar" # or "line"
        # Creates the Gruff Bar or Line Graph based on 'type'
        if type == "bar"  
            g = Gruff::Bar.new('800x500')
        elsif type == "line"
            g = Gruff::Line.new(400)
        end
        
        #g.no_data_message = "There is no cost data available for the range of dates you selected."
        #g.theme_greyscale
        g.theme_bp
        
        g.title = title
        g.font = File.expand_path('artwork/fonts/Vera.ttf', Rails.root) # Font selector
        # Column labels
        g.labels = labels

        # Modify this to represent your actual data models
        g.data(data_title, data)
        g.maximum_value = rounding(max)
        g.minimum_value = 0
        
        
        g.y_axis_increment = rounding(max * 0.10)
        
        
        #raise "#{max} #{rounding(max)}"
        g.draw_text_on_image(320,30, "#{Date.today.strftime('%m/%d/%Y')}")
        g.hide_legend = false
        g.x_axis_label = x_label
        g.y_axis_label = y_label
        
        bp_logo = "C:\\rails\\po_tracker\\public\\graphics\\bp-big.gif"
        
        #bp_logo = "C:\\rails\\po_tracker\\public\\graphics\\bp_logo.gif"
        g.add_image(bp_logo, 20, 20, 60, 80)
        #raise g.to_yaml
        #g.annotate(g.base_image, 600, 600, 100, 100, "teWxt")
    
        #g.annotate(g.base_image, scaled_width, scaled_height, x * scale, y * scale, text)
    
        #raise "#{g.to_yaml}"
        @filename = "graph.png"
        
        @image = g.to_blob('PNG')
        #@pdf = PDF::Writer.new(:orientation => :landscape, :justification => :left)
        #@pdf.add_image @image, 200, 200
        
        send_data @image, :filename => "jobs.png", :type => "image/png", :disposition => "inline"  
        
    end
  
    def render_multiple_graphs
    
    
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
