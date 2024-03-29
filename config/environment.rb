# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/app/reports )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "formtastic"
  config.gem "authlogic"
  config.gem "searchlogic"
  config.gem "jrails"
  config.gem "acts_as_list", "~>0.1"
  config.gem "acts_as_reportable", :lib => 'ruport/acts_as_reportable'
  config.gem "ruport"
  config.gem "will_paginate"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Eastern Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

Comatose.configure do |config|
  # Sets the text in the Admin UI's title area
  config.admin_title = "Online Market Site Content"
  config.admin_sub_title = "Substantive content for the site"
  config.default_tree_level   = 5
end

MEMBER_SURCHARGE = 0.00
PRODUCER_SURCHARGE = 0.05

Mime::Type.register 'application/pdf', :pdf

SOLD_BY_WEIGHT_EXPLANATION = "Products that are priced per pound but sold by the unit may vary in weight. Prices for products sold by weight are estimated price based on the average weight of a unit.  The actual prices for these products will be determined by actual weight at pick up."
