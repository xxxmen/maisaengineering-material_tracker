module MaterialRequestsHelper
  def m_disabled?
    @material_request.disabled_for?(current_employee)
  end
  
  def m_disabled_then(string)
    m_disabled? ? string : ''
  end
  
  def filter_url(filter_hash = {})
    new_params = params.merge(filter_hash)
    
    url = "/material_requests/?"
    
    if new_params[:status]
      url += "&amp;status=" + new_params[:status].to_s
    end
    if new_params[:requester]
      url += "&amp;requester=" + new_params[:requester].to_s
    end
    if new_params[:unit]
      url += "&amp;unit=" + new_params[:unit].to_s
    end
    if new_params[:group]
      url += "&amp;group=" + new_params[:group].to_s
    end
    
    return url
  end
  
  def not_purchaser?
    !current_employee.admin? && !current_employee.purchasing?
  end
            
  def link_to_orders(material_request)
  	pos = material_request.orders
    pos.map do |po|
      "<span id=\"po_link_#{po.id}\">" +
          link_to("#" + po.po_no.to_s, edit_order_path(po), :id=>"order_#{po.id.to_s}") + 
	  if current_employee.admin?
	  
	      "<a onclick=\"if (confirm('Are you sure you want to remove all links to #{po.po_no.to_s} from this Request?')) { new Ajax.Request('/material_requests/remove_po_links/#{material_request.id}?po_id=#{po.id}', {asynchronous:true, evalScripts:true}); }; return false;\" href=\"#\">(x)</a>"
  	  else
  	  	""
  	  end
	end.join(", ").html_safe

  end

  def link_to_quotes(material_request)
    quotes = material_request.quotes
    material_request_id = material_request.id

    quotes.map do |quote|
      if(!quote.vendor.blank?)
        #if we're hiding pricing, get rid of extra
        if(ResourcePermission.is_enabled?(:hide_pricing))
          link_to(quote.vendor.name, url_for(:controller => "material_requests", :action => "quote", :vendor_id => quote.vendor_id, :access_key => quote.vendor.access_key, :id => material_request_id))
        else
          link_to(quote.vendor.name + quote.filled_count + " ($" + number_with_precision(quote.total_price, {:precision => 2}) + ")", url_for(:controller => "material_requests", :action => "quote", :vendor_id => quote.vendor_id, :access_key => quote.vendor.access_key, :id => material_request_id))
        end
      end
    end.join(", ").html_safe
  end

  def link_to_quotes_comparison(material_request)
      link_to("<span style='font-size:10px;'>Compare Quotes</span>".html_safe, url_for(:controller => "material_requests", :action => "quote_comparison", :id => material_request.id))
  end
end
