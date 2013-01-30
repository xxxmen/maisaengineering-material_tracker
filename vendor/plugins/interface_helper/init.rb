require File.dirname(__FILE__) + '/lib/interface_form_builder'

ActionController::Base.helper InterfaceHelper
ActionController::Base.helper InterfaceHelper::ToggleHelper
ActionController::Base.helper InterfaceHelper::ButtonHelper

