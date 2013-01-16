require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require File.dirname(__FILE__) + '/post'
require File.dirname(__FILE__) + '/../lib/interface_form_builder'

class InterfaceFormBuilderTest < Test::Unit::TestCase  
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include SimplyHelpful::RecordIdentificationHelper
  include SimplyHelpful::RecordIdentifier
  
  def test_should_render_with_default
    assert true
  end    
  
  private
  def posts_url
    return "/posts/1"
  end
end
