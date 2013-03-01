MaterialTracker::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( base_packaged.js global_use.js vendor/yui.css printer.css base_packaged.css popv_packaged.js popv_packaged.css )


  config.action_mailer.default_url_options = { :host => 'mt-new31.herokuapp.com' }
  config.action_mailer.delivery_method = :smtp
  # ActionMailer::Base.default :from => "MAISA <maisa.engineers@gmail.com>"
  ActionMailer::Base.default :from => "MAISA <maisa.engineers@gmail.com>"

  config.action_mailer.smtp_settings = {
      enable_starttls_auto: true,
      address: 'smtp.gmail.com',
      port: 587,
      authentication: 'plain',
      user_name: 'maisa.engineers@gmail.com',
      password: 'MAISA@team777'
  }

  #config.action_mailer.delivery_method = :sendmail
  #config.action_mailer.smtp_settings = {
  #    :address => "localhost",
  #    :port => 25,
  #    :domain => ENV['MAIL_DOMAIN'],
  #    :user_name => "errors@#{ENV['MAIL_DOMAIN']}",
  #    :password => "none",
  #    :authentication => :login
  #}

  # Force all access to the app over SSL, use Strict-Transport-Security, and use s1.2.6ecure cookies.
  # config.force_ssl = true
  ThinkingSphinx.suppress_delta_output = true

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

  #ExceptionNotification configuration for rails 3.2
  config.middleware.use ExceptionNotifier,
                        app_name: "[po_tracker123@#{ENV['MAIL_DOMAIN']}]",
                        sender_address: 'maisa.engineers@gmail.com',
                        email_prefix: "[po_tracker123@#{ENV['MAIL_DOMAIN']}]",
                        exception_recipients: 'sukendhar555@gmail.com',
                        ignore_exceptions: ExceptionNotifier.default_ignore_exceptions # + [RuntimeError]


end
