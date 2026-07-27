# frozen_string_literal: true

module ActiveCurrency
  class Configuration
    def initialize
      @remote_bank = :eu_central_bank
      @open_exchange_rates_app_id = nil
      @multiplier = {}
      @cache_enabled = true
    end

    attr_accessor :remote_bank,
                  :open_exchange_rates_app_id,
                  :multiplier,
                  :cache_enabled

    def cache_enabled?
      !!@cache_enabled
    end
  end
end
