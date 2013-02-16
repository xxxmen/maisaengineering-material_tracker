module TicketsHelper

  def context_options(choice = nil)
    options = Ticket::CONTEXTS
    selected = options.include?(choice) ? choice : options[0]
    options_for_select(options, selected)
  end

  def priority_options(choice = nil)
    options = Ticket::PRIORITIES
    selected = options.include?(choice) ? choice : options[0]
    options_for_select(options, selected)
  end

  def state_options(choice = nil)
    options = Ticket::STATES
    selected = options.include?(choice) ? choice : options[1]
    options_for_select(options, selected)
  end

  def category_options(choice = nil)
    options = Ticket::CATEGORIES
    selected = options.include?(choice) ? choice : options[0]
    options_for_select(options, selected)
  end
  def filter_url(filter_hash = {})
    new_params = params.merge(filter_hash)

    url = "/tickets?"

    if new_params[:state]
      url += "&amp;state=" + new_params[:state].to_s
    end

    if new_params[:category]
      url += "&amp;category=" + new_params[:category].to_s
    end

    if new_params[:priority]
      url += "&amp;priority=" + new_params[:priority].to_s
    end


    return URI.escape(url)
  end
end
