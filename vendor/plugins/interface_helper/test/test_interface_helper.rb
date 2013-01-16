require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require File.dirname(__FILE__) + '/post'
require File.dirname(__FILE__) + '/../lib/interface_helper'

require 'action_view/test_case'


class InterfaceHelperTest < ActionView::TestCase
  include InterfaceHelper
  
  def test_link_to_help
    html = link_to_help('?', '/helpers/faq.html', :title => "Opens a new window with info")
    expected = link_to("?", '/helpers/faq.html', :popup => ['help_window', 'height=400,width=500,scrollbars=yes'], :title => "Opens a new window with info", :href => '/helpers/faq.html')
    assert_equal(expected, html)
    
    html = link_to_help('?', '/helpers/faq.html', :title => "Opens a new window with info", :height => 300, :width => 400, :scrollbars => "no")
    expected = link_to("?", '/helpers/faq.html', :popup => ['help_window', 'height=300,width=400,scrollbars=no'], :title => "Opens a new window with info", :href => '/helpers/faq.html')
    assert_equal(expected, html)
  end    
end
