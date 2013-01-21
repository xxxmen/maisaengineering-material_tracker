require 'test/unit'
require 'rubygems'
require 'stubba'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require File.dirname(__FILE__) + '/../lib/button_helper'
require File.dirname(__FILE__) + '/../lib/toggle_helper'
require File.dirname(__FILE__) + '/post'

require 'action_view/test_case'
require 'action_view/helpers/prototype_helper'

# Ripped out of action_pack/test/template/prototype_helper_test.rb
# Since I didn't know how to include it without the associated tests.
class PrototypeHelperBaseTest < ActionView::TestCase
  attr_accessor :template_format, :output_buffer

  def setup
    @template = self
    @controller = Class.new do
      def url_for(options)
        if options.is_a?(String)
          options
        else
          url =  "http://www.example.com/"
          url << options[:action].to_s if options and options[:action]
          url << "?a=#{options[:a]}" if options && options[:a]
          url << "&b=#{options[:b]}" if options && options[:a] && options[:b]
          url
        end
      end
    end.new
  end

  protected
    def request_forgery_protection_token
      nil
    end

    def protect_against_forgery?
      false
    end

    def create_generator
      block = Proc.new { |*args| yield *args if block_given? }
      JavaScriptGenerator.new self, &block
    end
end

class ButtonTest < PrototypeHelperBaseTest	
  include InterfaceHelper::ButtonHelper
  include InterfaceHelper::ToggleHelper
  # Needed in old Rails (1.2.x):
  #  include ActionView::Helpers::JavaScriptHelper
  #  include ActionView::Helpers::UrlHelper
  #  include ActionView::Helpers::TagHelper
  #  include ActionView::Helpers::PrototypeHelper
  
  def test_img_button
    html = img_button("text", "edit.png", "/posts/1")
    expected = span_button_for("text", "edit.png") do |text|
      link_to(text, "/posts/1")
    end
    assert_equal(expected, html)
  end
  
  def test_img_button_remote
    self.stubs(:url_for).returns("/posts/1")
    html = img_button_remote("text", "edit.png", :url => "/posts/1", :method => :get)
    expected = span_button_for("text", "edit.png") do |text|
      link_to_remote(text, :url => "/posts/1", :method => :get)
    end
    assert_equal(expected, html)
  end
  
  def test_img_button_toggle
    post = Post.new; post.save
    html = img_button_toggle("text", "edit.png", post, :show, :edit)
    expected = span_button_for("text", "edit.png") do |text|
      link_to_toggle(text, post, :show, :edit)
    end
    assert_equal(expected, html)
    
    post = Post.new; post.save
    html = img_button_toggle("text", "edit.png", post, :show, :edit, :title => "Toggles the form")
    expected = span_button_for("text", "edit.png") do |text|
      link_to_toggle(text, post, :show, :edit, :title => "Toggles the form")
    end
    assert_equal(expected, html)
  end
  
  def test_img_button_function
    html = img_button_function("text", "edit.png", "$('dom_id').focus()")
    expected = span_button_for("text", "edit.png") do |text|
      link_to_function(text, "$('dom_id').focus()")
    end
    assert_equal(expected, html)
  end
  
  private
  def span_button_for(button_name, img_path)
    text = '<img src="/images/icons/' + img_path + '" alt="Icon" />' + button_name
    return '<span class="button">' + (yield text) + '</span>'
  end
      
end
