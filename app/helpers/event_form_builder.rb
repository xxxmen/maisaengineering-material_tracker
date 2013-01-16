class EventFormBuilder < ActionView::Helpers::FormBuilder
  
  def text_field(method, options = {})
    super(method, options.merge(:onchange => "$('save-message').show(); new Effect.Highlight('save-message');" + (options[:onchange] || "")))  
  end
  
  def text_area(method, options = {})
    super(method, options.merge(:onchange => "$('save-message').show(); new Effect.Highlight('save-message');" + (options[:onchange] || "")))  
  end
  
  def select(method, items, default = {}, options = {})
    super(method, items, default, options.merge(:onchange => "$('save-message').show(); new Effect.Highlight('save-message');" + (options[:onchange] || "")))    
  end
  
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    super(method, options.merge(:onclick => "$('save-message').show(); new Effect.Highlight('save-message');" + (options[:onchange] || "")), checked_value, unchecked_value)  
  end
  
end