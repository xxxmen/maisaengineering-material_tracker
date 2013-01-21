module LiveHelper
  def add_to(page, record)
    record_type = record.is_a?(MaterialRequest) ? "material_requests" : "quotes"
    page << "if(!$('#{dom_id(record)}')){"
      page.insert_html :top, record_type, :partial => record_type, :locals => { record_type => [record], :hide => true }
      page.visual_effect :appear, dom_id(record)
    page << "}"
  end
  
  def remove_from(page, record)
    page << "if($('#{dom_id(record)}')){"
      page.visual_effect :fade, dom_id(record)
      page.delay(2) do
        page.replace dom_id(record), ""
      end
    page << "}"
  end
end
