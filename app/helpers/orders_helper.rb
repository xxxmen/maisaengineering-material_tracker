require 'uri'

module OrdersHelper
  def filter_url(filter_hash = {})
    new_params = params.merge(filter_hash)

    url = "/orders?"

    if new_params[:vendor]
      url += "&amp;vendor=" + new_params[:vendor].to_s
    end
    if new_params[:status]
      url += "&amp;status=" + new_params[:status].to_s
    end
    if new_params[:location]
      url += "&amp;location=" + new_params[:location].to_s
    end
    if new_params[:unit]
      url += "&amp;unit=" + new_params[:unit].to_s
    end
    if new_params[:state]
      url += "&amp;state=" + new_params[:state].to_s
    end
    if new_params[:year]
      url += "&amp;year=" + new_params[:year].to_s
    end
    if new_params[:group]
      url += "&amp;group=" + new_params[:group].to_s
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
