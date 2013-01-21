require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require File.dirname(__FILE__) + '/post'
require File.dirname(__FILE__) + '/../lib/toggle_helper'

class ToggleHelperTest < Test::Unit::TestCase
  include InterfaceHelper::ToggleHelper
  include ActionView::Helpers::JavaScriptHelper
  # Added these for Rails 2.3 compatibility
  include ActionController::RecordIdentifier
  include ActionView::Helpers::TagHelper
  
  def test_sould_generate_toggles
    js = toggle_items("dom_id")
    expected = "Element.toggle('dom_id'); "
    assert_equal(expected, js)
    
    js = toggle_items("first", "second")
    expected = "Element.toggle('first'); Element.toggle('second'); "
    assert_equal(expected, js)
  end
  
  def test_should_generate_toggles_with_new_record
    js = toggle_items(Post.new, "show")
    expected = "Element.toggle('show_post'); "
    assert_equal(expected, js)
    
    js = toggle_items(Post.new, "show", "form")
    expected = "Element.toggle('show_post'); Element.toggle('form_post'); "
    assert_equal(expected, js)
  end
  
  def test_should_generate_toggles_with_saved_record
    # A saved post has an id of 1
    post = Post.new
    post.save
    
    js = toggle_items(post, "show")
    expected = "Element.toggle('show_post_1'); "
    assert_equal(expected, js)
    
    js = toggle_items(post, "show", "form")
    expected = "Element.toggle('show_post_1'); Element.toggle('form_post_1'); "
    assert_equal(expected, js)
  end

  def test_should_scroll_to_an_element
    js = scroll_to("dom_id")
    expected = "$('dom_id').scrollTo(); "
    assert_equal(expected, js)
    
    post = Post.new; post.save
    js = scroll_to(post)
    expected = "$('edit_post_1').scrollTo(); "
    assert_equal(expected, js)
  end
  
  def test_should_focus_on_a_form
    js = focus_form("dom_id")
    expected = "$($('dom_id').findFirstElement()).focus(); "
    assert_equal(expected, js)
    
    js = focus_form(Post.new)
    expected = "$($('new_post').findFirstElement()).focus(); "
    assert_equal(expected, js)
    
    post = Post.new
    post.save
    js = focus_form(post)
    expected = "$($('edit_post_1').findFirstElement()).focus(); "
    assert_equal(expected, js)    
  end
  
  def test_should_activate_on_a_form
    js = activate_form("dom_id")
    expected = "$('dom_id').focusFirstElement(); "
    assert_equal(expected, js)
    
    js = activate_form(Post.new)
    expected = "$('new_post').focusFirstElement(); "
    assert_equal(expected, js)
    
    post = Post.new; post.save
    js = activate_form(post)
    expected = "$('edit_post_1').focusFirstElement(); "
    assert_equal(expected, js)    
  end
      
  def test_should_generate_link_to_toggle
    html = link_to_toggle("text", "dom_id")
    expected = link_to_function("text", toggle_items("dom_id"))
    assert_equal(expected, html)
    
    html = link_to_toggle("text", "dom_id", "dom_id2", "dom_id3")
    expected = link_to_function("text", toggle_items("dom_id", "dom_id2", "dom_id3"))
    assert_equal(expected, html)
    
    html = link_to_toggle("text", Post.new, "edit", "form")
    expected = link_to_function("text", toggle_items(Post.new, "edit", "form"))
    assert_equal(expected, html)
    
    post = Post.new; post.save
    html = link_to_toggle("text", post, "edit", "form")
    expected = link_to_function("text", toggle_items(post, "edit", "form"))
    assert_equal(expected, html)
  end
  
  def test_should_generate_link_to_toggle_with_focus_and_activate
    html = link_to_toggle("text", "dom_id", :focus => "dom_id")
    expected = link_to_function("text", toggle_items("dom_id") + focus_form("dom_id"))
    assert_equal(expected, html)
    
    post = Post.new; post.save
    html = link_to_toggle("text", post, :show, :form, :activate => post, :title => "link_title")
    expected = link_to_function("text", toggle_items(post, :show, :form) + activate_form(post), :title => "link_title")
    assert_equal(html, expected)
  end
  
  def test_should_generate_link_to_toggle_with_scroll_to
    html = link_to_toggle("text", "dom_id", :scroll_to => "dom_id")
    expected = link_to_function("text", toggle_items("dom_id") + scroll_to("dom_id"))
    assert_equal(expected, html)
  end
  
  def test_should_generate_link_to_toggle_with_options
    html = link_to_toggle("text", "dom_id", :id => "link_id", :title => "link_title")
    expected = link_to_function("text", toggle_items("dom_id"), :id => "link_id", :title => "link_title")
    assert_equal(expected, html)
    
    post = Post.new; post.save
    html = link_to_toggle("text", post, "edit", "form", :id => "link_id", :title => "link_title")
    expected = link_to_function("text", toggle_items(post, "edit", "form"), :id => "link_id", :title => "link_title")
    assert_equal(expected, html)
  end
    
end
