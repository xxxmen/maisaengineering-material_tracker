# Define SimplyHelpful in case it's not already defined
module SimplyHelpful
  module RecordIdentificationHelper; end;
  module RecordIdentifier; end;
end unless Object.const_defined?("SimplyHelpful")

class InterfaceFormBuilder < ActionView::Helpers::FormBuilder
  include SimplyHelpful::RecordIdentificationHelper
  include SimplyHelpful::RecordIdentifier
  
  def text_field(field, options = {})    
    set_defaults(field, options)
    super(field, options)
  end  
  
  def text_area(field, options = {})    
    set_defaults(field, options)
    super(field, options)
  end 
  
  private
  def set_defaults(field, options)
    if @object.new_record? && (options[:default] || options[:onblank])
      options[:style] = (options[:style] || '') + "color: gray; font-style: italic;"
      options[:onfocus] = (options[:onclick] || '') + "InterfaceHelper.clear(this);"
      options[:onblur] = (options[:onblur] || '') + "InterfaceHelper.reset(this);" if options[:onblank]
      options[:value] = @object.send(field) || options.delete(:default) || options.delete(:onblank)
    end
  end
  
end