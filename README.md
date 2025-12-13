# ActiveCurrency

Rails plugin to retrieve and store the currency rates daily to integrate
with the [money-rails] gem.

## Rationale

Storing the current currency rates with ActiveCurrency provides the following
advantages:

- Lets you query for the currency rate you actually used in your application at
  any given time.
- Does not need to call an API to get the rates when starting or restarting
  your web server.
- Does not depend on the file system to store cached rates.
- Choose how often you want to update the currency rates (daily for example).
- Your users do not suffer the cost of making calls to the bank rates API.
- Your app does not go down when the bank rates API does.

To fetch the *current* rate it uses your application cache instead of making
a call to the database.

## Usage

Store the current rate regularly by calling in a scheduled job (using something
like [sidekiq-scheduler], [whenever], or [active_scheduler]) with the currencies
you want to store:

```rb
ActiveCurrency::AddRates.call(currencies: %w[EUR USD])
```

You can then exchange money by using the Money gem helpers:

```rb
10.to_money('EUR').exchange_to('USD').cents
```

If you need to look up the previous currency rates:

```rb
ActiveCurrency::Rate.value_for('EUR', 'USD', 1.month.ago)
# => 1.151
ActiveCurrency::Rate.where(from: 'EUR', to: 'USD').pluck(:value)
# => [1.162, 1.162, 1.161, 1.161, 1.163, …]
```

## Installation

Add these lines to your application’s `Gemfile`:

```rb
# Store and retrieve the currency from the database.
gem 'active_currency'
```

And in `config/initializers/money.rb`:

```rb
MoneyRails.configure do |config|
  config.default_bank = ActiveCurrency::Bank.new
end
```

Then call `bin/rake db:migrate` to create the table that holds
the currency rates and fill it for the first time.

## Fetching rates

Call the following regularly in a scheduled job:

```rb
ActiveCurrency::AddRates.call(currencies: %w[EUR USD])
```

The first currency you give in `currencies` is considered the default currency
against which other currency rates will be guessed if they are unavailable.

### Fetching from the European Central Bank

By defaut it uses the [eu_central_bank] to fill the currency rates.

### Fetching from openexchangerates.org

To use the [money-open-exchange-rates] gem, add the gem to your `Gemfile`, then
add the following to your application’s initializers:

```rb
ActiveCurrency.configure do |config|
  config.remote_bank = :open_exchange_rates
  config.open_exchange_rates_app_id = '…'
end
```

### Fetching from a custom bank

You can provide any Money-compatible bank when calling
`ActiveCurrency::AddRates`:

```rb
ActiveCurrency::AddRates.call(…, bank: …)
```

## Apply a multiplier

If you want to increase or decrease the currency rates by a given multiplier,
you can do so by setting the `multiplier` option:

```rb
ActiveCurrency.configure do |config|
  config.multiplier = {
    ["EUR", "USD"] => 1.01,
  }
end
```

## Tests

In your app test suite you may not want to have to fill your database to be
able to exchange currencies.

For that, you can use a fake rate store in your `rails_helper.rb`:

```rb
MoneyRails.configure do |config|
  rate_store = Money::RatesStore::Memory.new.tap do |store|
    store.add_rate('USD', 'EUR', 1.5)
    store.add_rate('EUR', 'USD', 0.67)
  end
  config.default_bank = Money::Bank::VariableExchange.new(rate_store)
end
```

## Contributing

Please file issues and pull requests [on GitHub].

## Development

Install:

```sh
BUNDLE_GEMFILE=Gemfile-rails7.0 bundle install
```

Launch specs and linters:

```sh
BUNDLE_GEMFILE=Gemfile-rails7.0 bin/rake
```

## Release

Update `CHANGELOG.md`, update version in `lib/active_currency/version.rb`.

Then:

```sh
BUNDLE_GEMFILE=Gemfile-rails6.1 bundle update
BUNDLE_GEMFILE=Gemfile-rails7.0 bundle update

git add CHANGELOG.md lib/active_currency/version.rb Gemfile-rails*
git commit -m v`ruby -r./lib/active_currency/version <<< 'puts ActiveCurrency::VERSION'`
bin/rake release
```

## License

The gem is available as open source under the terms of the [MIT License].

[money-rails]: https://github.com/RubyMoney/money-rails
[sidekiq-scheduler]: https://github.com/Moove-it/sidekiq-scheduler
[whenever]: https://github.com/javan/whenever
[active_scheduler]: https://github.com/JustinAiken/active_scheduler
[eu_central_bank]: https://github.com/RubyMoney/eu_central_bank
[money-open-exchange-rates]: https://github.com/spk/money-open-exchange-rates
[on GitHub]: https://github.com/RubyMoney/active_currency
[MIT License]: http://opensource.org/licenses/MIT
