# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "active_currency/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "active_currency"
  s.version = ActiveCurrency::VERSION
  s.authors = ["Sunny Ripert"]
  s.email = ["sunny@sunfox.org"]
  s.homepage = "https://github.com/RubyMoney/active_currency"
  s.summary = "Rails plugin to store your currency regularly"
  s.description = "Store your currency."
  s.license = "MIT"
  s.metadata["rubygems_mfa_required"] = "true"

  s.files =
    Dir["{app,db,lib}/**/*", "MIT-LICENSE", "README.md"]

  # Gem dependencies

  # Rails plugin.
  s.add_dependency "rails", ">= 4.2"

  # The Rails app needs to use money-rails as well.
  s.add_dependency "money-rails"

  # Handle database transactions.
  s.add_dependency "after_commit_everywhere", ">= 1.3.0"

  # API to get the currencies.
  # >= 1.3.1 to prevent HTTPS error.
  s.add_dependency "eu_central_bank", ">= 1.3.1"

  # Development dependencies

  # API to get the currencies.
  s.add_development_dependency "money-open-exchange-rates"

  # DB for the dummy app.
  s.add_development_dependency "sqlite3"

  # Unit testing.
  s.add_development_dependency "rspec"

  # Unit testing with rails.
  s.add_development_dependency "rspec-rails"

  # Spec formatter for GitHub Actions.
  s.add_development_dependency "rspec-github"

  # Formatter for unit testing that Circle-CI enjoys.
  s.add_development_dependency "rspec_junit_formatter"

  # Travel through time in specs.
  s.add_development_dependency "timecop"

  # Useful for `binding.pry` in development.
  s.add_development_dependency "pry"

  # Style guide.
  s.add_development_dependency "rubocop"

  # Style guide for Rails.
  s.add_development_dependency "rubocop-rails"

  # Style guide for RSpec.
  s.add_development_dependency "rubocop-rspec"
end
