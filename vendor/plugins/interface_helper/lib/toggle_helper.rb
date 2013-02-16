# Define SimplyHelpful in case it's not already defined
module SimplyHelpful
  module RecordIdentificationHelper; end;
end unless Object.const_defined?("SimplyHelpful")

module InterfaceHelper
  # Includes methods that help with toggling items on a page.
  module ToggleHelper

    include SimplyHelpful::RecordIdentificationHelper
    include ActionView::Helpers::JavaScriptHelper

    # Generates the Javascript to toggle each item.
    # Assumes Prototype library is already included.
    #
    # Example:
    #
    #    toggle_items("edit_post_1", "show_post_1")
    #
    # This toggles html elements with id 'edit_post_1' and 'show_post_1'
    #
    #    post = Post.new; post.save!
    #    toggle_items(post, :edit, :form)
    #
    # Assuming post.id = 1, this method will use SimplyHelpful's dom_id and
    # toggle the html elements with 'edit_post_1' and 'show_post_1'
    def toggle_items(*args)
      record = args.first.is_a?(String) ? nil : args.shift
      args.collect do |arg|
        "Element.toggle('#{prefix_or_dom_id(record, arg)}'); "
      end.join('') #rupgrade Rails3:  removed .to_s and used join('')
    end

    def scroll_to(record_or_id)
      javascript_for_element(record_or_id) do |element_id|
        "$('#{element_id}').scrollTo(); "
      end
    end

    # Pass in a dom_id of a form and this method will put the focus
    # onto the first input of that form.
    #
    # Pass in an ActiveRecord record and this method will place focus
    # onto the record's corresponding form_for.
    #
    # Example:
    #
    #    focus_form('my_form')       # puts focus on first element of form with id 'my_form'
    #    focus_form(Post.new)        # puts focus on first element of form with id 'new_post'
    #    post = Post.new; post.save  # Saves post with id = 1
    #    focus_form(post)            # puts focus on first element of form with id 'edit_post_1'
    def focus_form(record_or_id)
      javascript_for_element(record_or_id) do |form_id|
        "$($('#{form_id}').findFirstElement()).focus(); "
      end
    end

    # Same as the method focus_form, execept it will put focus and select the contents
    # of the input.  This is known as 'activating' the input.
    def activate_form(record_or_id)
      javascript_for_element(record_or_id) do |form_id|
        "$('#{form_id}').focusFirstElement(); "
      end
    end

    # Produces a link that will toggle elements on the current page.  This uses the method
    # toggle_items, so the arguments are just like that except it produces a link_to call it.
    #
    # Basic Usage:
    #
    #     <%= link_to_toggle "Edit Post", "edit_post_1", "show_post_1" %>
    #
    # This toggles elements with id "edit_post_1" and "show_post_1"
    #
    #     <% post = Post.new; post.save! # Saves with id = 1 %>
    #     <%= link_to_toggle "Edit Post", post, :edit, :show %>
    #
    # This toggles elements with id "edit_post_1" and "show_post_1"
    #
    #     <%= link_to_toggle "Edit Post", post, :edit, :show, :focus => post %>
    #
    # The :focus option will call focus_form on post.  So after toggling the form,
    # Javascript will be used to put focus on the first element of the form.
    # You can also use the option :activate to activate the first element.
    # FIXME: Generates an extra semi-colon for onclick event handler (get rid of it)
    def link_to_toggle(text, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      return link_to_function(text, toggle_items(*args) + focus_form(options.delete(:focus)) +
          activate_form(options.delete(:activate)) +
          scroll_to(options.delete(:scroll_to)), options)
    end

    private
    def prefix_or_dom_id(record, prefix = nil)
      record ? dom_id(record, prefix) : prefix
    end

    def form_dom_id(record, prefix = nil)
      record.new_record? ? dom_id(record) : dom_id(record, :edit)
    end

    def javascript_for_element(record_or_id)
      return "" unless record_or_id
      form_id = record_or_id.is_a?(String) ? record_or_id : form_dom_id(record_or_id)
      yield form_id
    end

  end
end