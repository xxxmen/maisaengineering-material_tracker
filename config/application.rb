require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  Bundler.require *Rails.groups(:assets => %w(development test))
end
load(File.expand_path('../rails3_env_constants.rb', __FILE__))

#load(File.expand_path('../app_constants', __FILE__))

module MaterialTracker
  class Application < Rails::Application

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.assets.initialize_on_precompile = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{Rails.root}/lib)
    config.autoload_paths += Dir["#{Rails.root}/lib/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    #Rails default includes all the helpers(but if we give the same method names in multiple helpers which method will be called we don't know)
    #Ruby doesn't support method overloading
    #by putting false in below line, controller specific helpers will available to that controller only instead of all helpers
    config.action_controller.include_all_helpers = false


    #ExceptionNotification used as gem for rails 3.2
    ##ExceptionNotification.exception_recipients = %w(errors@telaeris.com)
    ##ExceptionNotification.email_prefix = "[po_tracker@#{ENV['MAIL_DOMAIN']}] "
    ##ExceptionNotification.sender_address = %("PO Tracker Error" <po_tracker@#{ENV['MAIL_DOMAIN']}>)
    #ExceptionNotification::Notifier.configure_exception_notifier do |config|
    #  config[:app_name]                 = "[po_tracker@#{ENV['MAIL_DOMAIN']}]"
    #  config[:sender_address]           = "#{ENV['DEPLOY_SITE_NAME']} <po_tracker@#{ENV['MAIL_DOMAIN']}>"
    #  config[:subject_prepend]          = "[po_tracker@#{ENV['MAIL_DOMAIN']}]"
    #  config[:exception_recipients]     = ["errors@telaeris.com"] # You need to set at least one recipient if you want to get the notifications
    #
    #  # In a local environment only use this gem to render, never email
    #  #defaults to false - meaning by default it sends email.  Setting true will cause it to only render the error pages, and NOT email.
    #  config[:skip_local_notification]  = true
    #  # Error Notification will be sent if the HTTP response code for the error matches one of the following error codes
    #  config[:notify_error_codes]   = %W( 405 500 503 )
    #  # Error Notification will be sent if the error class matches one of the following error classes
    #  config[:notify_error_classes] = %W( )
    #  # What should we do for errors not listed?
    #  config[:notify_other_errors]  = true
    #end


  end

end

