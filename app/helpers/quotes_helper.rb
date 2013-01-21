require 'uri'

module QuotesHelper
  def filter_url(filter_hash = {})
    new_params = params.merge(filter_hash)
    
    url = "/quotes?"
    
    if new_params[:vendor]
      url += "&amp;vendor=" + new_params[:vendor].to_s
    end

    
    return URI.escape(url)
  end
  
  def link_to_requests(material_requests)
    links = material_requests.map do |request|
      href = edit_material_request_path(request)
      tracking = request.tracking
      "<a href='#{href}'>#{tracking}</a>"
    end
    return links.join(", ")
  end
  
    def group_options(choice = nil)
    groups = Group.list_all_for_select
    options_for_select(groups, choice)
  end
end
