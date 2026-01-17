# frozen_string_literal: true

module ActiveCurrency
  class Bank < Money::Bank::VariableExchange
    def initialize(rate_store = ActiveCurrency::RateStore.new)
      super
    end
  end
end
