# frozen_string_literal: true

module ActiveCurrency
  class RateStore < DatabaseStore
    include CacheableStore

    # Money::Bank::VariableExchange#marshal_load rebuilds the store with
    # `store_info.shift.new(*store_info)`, so a store's #marshal_dump must
    # return `[StoreClass, *constructor_args]`. RateStore takes no arguments,
    # so returning `[self.class]` lets a bank backed by this store be
    # marshaled -- for example when the configured default bank is cached
    # under a Marshal-based cache/serializer.
    def marshal_dump
      [self.class]
    end
  end
end
