require 'uri'

module EventsHelper
  def filter_url(filter_hash = {})
    new_params = params.merge(filter_hash)
    
    url = "/events?"
    
    if new_params[:employee]
      url += "&amp;employee=" + new_params[:employee].to_s
    end
    if new_params[:record]
      url += "&amp;record=" + new_params[:record].to_s
    end
    
    return URI.escape(url)
  end
end