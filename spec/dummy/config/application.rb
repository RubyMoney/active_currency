# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

require "active_currency"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults Rails.version.to_f

    if config.active_record.sqlite3
      config.active_record.sqlite3.represent_boolean_as_integer = true
    end
  end
end
