module ReportsHelper
  def days_overdue(order)
    order.date_eta ? (Date.today - order.date_eta) : ""
  end
  
  def show_item(item, group)
    group_by = group.to_sym
    if group_by == :po_no
      return "PO# #{(item || 'NONE')}"
    elsif group_by == :wo_no1
      return "WO# #{(item || 'NONE')}"
    elsif group_by == :tracking
      return "Tracking ##{(item || 'NONE')}"
    elsif group_by == :ptm_no
      return "PTM# #{(item || 'NONE')}"
    elsif group_by == :date_eta
      return (item.blank? ? "NO ETA" : item.strftime("%A, %B %d, %Y"))
    elsif group_by == :vendor_id
      unless item.blank?
        vendor = Vendor.find(item)
        name = vendor.name || ""
        telephone = vendor.telephone || ""
      end
      return (item.blank? ? "NO VENDOR" : (name + " - " + telephone))
    elsif group_by == :unit_id
      return (item.blank? ? "NO UNIT" : Unit.find(item).description)
    end
  rescue ActiveRecord::RecordNotFound
    return "Unspecified"
  end
  
  
  
end
