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
  s.homepage = "https://github.com/sunny/active_currency"
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
end
