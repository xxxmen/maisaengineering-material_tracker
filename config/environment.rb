# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Be sure to restart your web server when you modify this file.

#require File.join(File.dirname(__FILE__), 'app_constants')

# Bootstrap the Rails environment, frameworks, and default configuration
require File.expand_path('../../config/boot', __FILE__)

class Rails::Boot
  def run
    load_initializer

    Rails::Initializer.class_eval do
      def load_gems
        @bundler_loaded ||= Bundler.require :default, Rails.env
      end
    end

    Rails::Initializer.run(:set_load_path)
  end
end


Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  #config.gem 'CSV'
  #config.gem 'bluecloth', 						:version => '>= 2.0.0'

  # Be sure to change the gem version reference in RAILS_ROOT/Rakefile
  # if you update this definition at all.
  # config.gem 'thinking-sphinx', :version => '>= 1.4.11',
  # 		:lib => 'thinking_sphinx',
  # 		:source => 'http://gemcutter.org'

  # config.gem 'ts-datetime-delta',
  # 		:lib     => 'thinking_sphinx/deltas/datetime_delta',
  # 		:source => 'http://gemcutter.org'


  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]


  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
 # config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir|
 #   File.directory?(lib = "#{dir}/lib") ? lib : dir
 # end

  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.smtp_settings = {
    :address => "localhost",
    :port => 25,
    :domain => ENV['MAIL_DOMAIN'],
    :user_name => "errors@#{ENV['MAIL_DOMAIN']}",
    :password => "none",
    :authentication => :login
  }

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store
  # TODO: Make the cookie secret more secure.
  config.action_controller.session = {
  	:key => '_po_tracker_session',
  	:secret => "172098c254e76ddfbf01f7bf8247cd2a626381c007bdc8e22c4cb77f9d2bd729be0f85b264836e34f02ce1e82cd99f73038bb8fa7fb60e9b421a26e044ff65a1"
  }


  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # See Rails::Configuration for more options
end

#require 'fastercsv'
#require 'json'
#require "acts_as_ferret"
#require 'bluecloth'
#require 'thinking_sphinx'
require 'thinking_sphinx_extensions' # in RAILS_ROOT/lib
require 'piping_reference_helper' # in RAILS_ROOT/lib
#require 'report'		# Make sure the extra classes defined in report.rb are loaded.
#require 'asset'
# Special gruff scripts to generate pretty graphs in the reports controller!
#Dir.glob(RAILS_ROOT + '/lib/gruff_graphs/*') do |file|
#    require file
#end

# Extends Gruff with the custom methods in /lib/gruff_extender.rb
# Gruff::Base.send(:include, GruffExtender)

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

ActiveSupport::Inflector.inflections do |i|
  i.irregular 'valve', 'valves'
end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# TODO: Move this line out - doesn't belong here!
# For some reason, calling to_json on an ActiveRecord object will return the object.to_s
# Ex: <Vendor:#141231>
# This line will force the record to return a JSON form of its attributes
ActiveRecord::Base.class_eval { define_method(:to_json) { self.attributes.to_json } }

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(:default => '%m/%d/%Y %I:%M %p')
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(:date_only => '%m/%d/%Y')


class Array
  def to_csv(options = {})
    # If the array is filled with AR objects, parse its attributes
    if self.length == 0
      ""
    elsif all? { |e| e.respond_to?(:to_row) }
      header_row = first.class.column_names.to_csv
      content_rows = map { |e| e.to_row }.map { |r| r.to_csv }
      ([header_row] + content_rows).join
    else
      FasterCSV.generate_line(self, options)
    end
  end
end

# Temporary fix for paperclip. See:
# https://thoughtbot.lighthouseapp.com/projects/8794-paperclip/tickets/158-clearing-an-attachment-from-a-new-record-throws-an-error-upon-save
#
module Paperclip
  # The Attachment class manages the files for a given attachment. It saves
  # when the model saves, deletes when the model is destroyed, and processes
  # the file upon assignment.
  class Attachment
  	def clear
      queue_existing_for_delete
      @queued_for_write  = {}
      @errors            = {}
      @validation_errors = nil
    end
  end
end

#class Hash
#    def has?(*args)
#      current = self
#      args.each do |arg|
#        if current.has_key?(arg)
#          current = current[arg]
#        else
#          current = nil
#          break
#        end
#      end
#
#      return current
#    end
#end

require File.dirname(__FILE__) + "/../lib/filter_foo"

#ExceptionNotification.exception_recipients = %w(errors@telaeris.com)
#ExceptionNotification.email_prefix = "[po_tracker@#{ENV['MAIL_DOMAIN']}] "
#ExceptionNotification.sender_address = %("PO Tracker Error" <po_tracker@#{ENV['MAIL_DOMAIN']}>)
ExceptionNotification::Notifier.configure_exception_notifier do |config|
  config[:app_name]                 = "[po_tracker@#{ENV['MAIL_DOMAIN']}]"
  config[:sender_address]           = "#{ENV['DEPLOY_SITE_NAME']} <po_tracker@#{ENV['MAIL_DOMAIN']}>"
  config[:subject_prepend]          = "[po_tracker@#{ENV['MAIL_DOMAIN']}]"
  config[:exception_recipients]     = ["errors@telaeris.com"] # You need to set at least one recipient if you want to get the notifications

  # In a local environment only use this gem to render, never email
  #defaults to false - meaning by default it sends email.  Setting true will cause it to only render the error pages, and NOT email.
  config[:skip_local_notification]  = true
  # Error Notification will be sent if the HTTP response code for the error matches one of the following error codes
  config[:notify_error_codes]   = %W( 405 500 503 )
  # Error Notification will be sent if the error class matches one of the following error classes
  config[:notify_error_classes] = %W( )
  # What should we do for errors not listed?
  config[:notify_other_errors]  = true
end

MAIL_TEST_EMAIL = 'errors@telaeris.com'

module ActionView::Helpers::JavaScriptMacrosHelper
end

class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

if "irb" == $0
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
