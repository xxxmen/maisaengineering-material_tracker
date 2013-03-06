source 'http://rubygems.org'

gem 'rails', '3.2.11'
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Database for application
gem 'mysql2'

# Needed for the new asset pipeline
group :assets do
  gem 'sass-rails',   "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier',     ">= 1.0.3"
  gem 'therubyracer', '0.11.1', :platform => :ruby
end

gem 'libv8', '~> 3.11.8'

# jQuery is the default JavaScript library in Rails 3.1
gem 'jquery-rails'
gem 'paperclip'
gem "will_paginate", ">= 3.0.pre2"

#gem 'thinking-sphinx'#, '~>2.0.10'#, :require => 'thinking_sphinx'
gem 'thinking-sphinx',
    :git => 'git://github.com/pat/thinking-sphinx.git',
    :ref => '8f0e34b4a68494738d8dd5a1cb6bcf379adbf640'

gem 'ts-datetime-delta', '1.0.2',
    :require => 'thinking_sphinx/deltas/datetime_delta'

#gem "rake", "~>0.8.3"

gem "test-unit", "~> 2.4.0"
gem "prototype-rails"
gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git'
gem 'to-csv'
gem "comma", "~> 3.0"
gem 'json','1.7.7'
gem 'exception_notification'
gem 'thin'

group :development, :test do
  gem 'ruby-debug19'
  gem 'rspec-rails', '~> 2.6.1.beta1'
  gem 'rspec', '~> 2.6'
  gem "factory_girl_rails"
end

