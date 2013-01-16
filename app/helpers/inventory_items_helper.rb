module InventoryItemsHelper
  def filter_url(filter_hash = {})
    new_params = params.merge(filter_hash)
    
    url = "/inventory_items"
    
    if new_params[:vendor_name]
      url += "?vendor_name=" + new_params[:vendor_name].to_s
    end
    
    return url
  end
end
