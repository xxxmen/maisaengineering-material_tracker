require File.dirname(__FILE__) + '/toggle_helper'
require File.dirname(__FILE__) + '/button_helper'

# Inclues a lot of methods that will help with the interface.
# All methods included are available from ERB.
# Uses SimplyHelpful for some cases.
module InterfaceHelper
  include ActionView::Helpers::UrlHelper
  
  # Generates a link to a pop up window (so users can 
  # click on it an see a FAQs pop up or further instructions)
  #
  # Example:
  #   <%= link_to_help "/faqs/index.html" %>
  #   <%= link_to_help "/faqs/index.html", :width => 500, :height => 400 %>
  #   <%= link_to_help "/faqs/index.html", :scrollbars => "yes" %>
  #
  # Each call produces <a href="/faqs/index.html" onclick="window.open('/faqs/index.html')">?<?a>.
  # You can set the size of the open window by using the width/height option,
  # and you can set scrollbars with "yes" or "no".
  def link_to_help(text, path, html_options = {})
    height = html_options.delete(:height) || "400" 
    width = html_options.delete(:width) || "500"
    scrollbars = html_options.delete(:scrollbars) || "yes"
    html_options.merge!(:popup => ['help_window', 
         "height=#{height.to_s},width=#{width.to_s},scrollbars=#{scrollbars.to_s}"],
          :href => path)
    link_to(text, path, html_options)
  end
  
  def tabular_form_for(*args, &proc)
    if args.last.is_a?(Hash)
      args.last[:builder] = TabularFormBuilder
    else
      args << { :builder => TabularFormBuilder }
    end
    
    concat("<table cellspacing=\"0\">", proc.binding)
    form_for(*args, &proc)
    concat("</table>", proc.binding)
  end
  
  def tabular_remote_form_for(*args, &proc)
    if args.last.is_a?(Hash)
      args.last[:builder] = TabularFormBuilder
    else
      args << { :builder => TabularFormBuilder }
    end
    
    concat("<table cellspacing=\"0\">", proc.binding)
    remote_form_for(*args, &proc)
    concat("</table>", proc.binding)
  end
  
end