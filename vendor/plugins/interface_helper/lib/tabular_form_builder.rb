require File.dirname(__FILE__) + '/interface_form_builder'
require File.dirname(__FILE__) + '/interface_helper'

class TabularFormBuilder < InterfaceFormBuilder
  include SimplyHelpful::RecordIdentificationHelper
  include SimplyHelpful::RecordIdentifier
  
  def text_field(field, options = {})    
    tabelize_input(field, options) do
      super(field, options)
    end
  end  
  
  def text_area(field, options = {})    
    tabelize_input(field, options) do
      super(field, options)
    end
  end 
  
  def date_select(field, options = {})
    tabelize_input(field, options) do
      super(field, options)
    end
  end

  def select(field, choices, options = {}, html_options = {})
    tabelize_input(field, options) do
      super(field, choices, options, html_options)
    end
  end
  
  private
  def tabelize_input(field, options = {})
    label = options.delete(:label) || field
    required = "<span class=\"required\">*</span>"
    required = "" unless options.delete(:required)
    help = "&nbsp;<a href=\"#{options[:help]}\" 
            onclick=\"window.open('#{options[:help]}', 'help',      
                     'height=400,width=500,scrollbars=yes'); return false;\">?</a>"
    help = "" unless options.delete(:help)
    
    return "<tr>" +
           "<th><label for=\"#{dom_class(@object) + "_" + field.to_s}\">" + 
           label.to_s.humanize + ":</label>" +
           required + "</th><td>" + yield + help + "</td></tr>"
  end
  
end