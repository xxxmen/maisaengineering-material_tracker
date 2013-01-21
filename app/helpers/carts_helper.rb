module CartsHelper
  def c_submitted_or_empty?(string)
    !@cart.processing? || @cart.cart_items.size == 0 ? string : ''
  end
  
  def filter_url(filter_hash = {})
    new_params = params.merge(filter_hash)
    
    url = "/carts/recent/?status=all"
    
    if new_params[:requester]
      url += "&amp;requester=" + new_params[:requester].to_s
    end
    if new_params[:unit]
      url += "&amp;unit=" + new_params[:unit].to_s
    end
    
    return url
  end
end
