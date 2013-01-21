require "#{File.dirname(__FILE__)}/../test_helper"

class SpiderTest < ActionController::IntegrationTest
  fixtures :employees, :material_requests, :requested_line_items, :carts, :cart_items, :purchase_orders, :ordered_line_items, :units, :vendors, :companies
  include Caboose::SpiderIntegrator

  def test_spider
    get '/'
    login_as(:bp)
    get '/material_requests/'    
    spider(@response.body, '/material_requests/', {})    
    spider(@response.body, '/material_requests/edit/1/', {})
  end

  def login_as(employee)
    @request.session[:employee] = 1
  end
end
