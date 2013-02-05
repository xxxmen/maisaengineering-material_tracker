module InterfaceHelper
  # Includes methods that help with creating nice icon buttons
  module ButtonHelper

    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::UrlHelper
    #include ActionView::Helpers::PrototypeHelper

    def img_button(button_name, img_path, url_path, *args)
      return span_button_for(button_name, img_path) do |text|
        link_to(text, url_path, *args)
      end
    end

    def img_button_remote(button_name, img_path, *args)
      return span_button_for(button_name, img_path) do |text|
        link_to_remote(text, *args)
      end
    end

    def img_button_toggle(button_name, img_path, *args)
      return span_button_for(button_name, img_path) do |text|
        link_to_toggle(text, *args)
      end
    end

    def img_button_function(button_name, img_path, *args)
      return span_button_for(button_name, img_path) do |text|
        link_to_function(text, *args)
      end
    end

    private
    def span_button_for(button_name, img_path)
      #text = "<img src=\"/assets/icons/" + img_path + '" alt="Icon" />' + button_name
      text = image_tag("icons/#{img_path}",alt: 'Icon') + button_name
      "<span class='button'>  #{yield text} </span>".html_safe
    end

  end
end