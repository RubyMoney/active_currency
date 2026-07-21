# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveCurrency::RateStore do
  let(:store) { described_class.new }

  before do
    # Mock cache
    allow(Rails.cache).to receive(:fetch).and_yield
    allow(Rails.cache).to receive(:delete)

    # Mock database
    allow(ActiveCurrency::Rate).to receive(:value_for).and_return(1.5)
  end

  # Mock time
  around do |example|
    Timecop.freeze(Time.new(2000, 1, 1).utc, &example)
  end

  describe "#get_rate" do
    context "without a date" do
      let(:get_rate) { store.get_rate("EUR", "USD") }

      it "calls the database" do
        expect(get_rate).to eq(1.5)
        expect(ActiveCurrency::Rate)
          .to have_received(:value_for)
          .with("EUR", "USD", nil)
      end

      it "calls the cache" do
        get_rate

        expect(Rails.cache)
          .to have_received(:fetch)
          .with(%w[active_currency_rate EUR USD], expires_in: 1.hour)
      end

      context "with a full cache" do
        before do
          allow(Rails.cache).to receive(:fetch).and_return(99.99)
        end

        it "returns the cached value" do
          expect(get_rate).to eq(99.99)
        end

        it "does not call the database" do
          get_rate

          expect(ActiveCurrency::Rate).not_to have_received(:value_for)
        end
      end
    end

    context "with a date" do
      let(:date) { 1.day.ago }

      it "calls the database" do
        expect(store.get_rate("EUR", "USD", date)).to eq(1.5)
        expect(ActiveCurrency::Rate)
          .to have_received(:value_for)
          .with("EUR", "USD", date)
      end

      it "does not call the cache" do
        store.get_rate("EUR", "USD", date)

        expect(Rails.cache).not_to have_received(:fetch)
      end
    end
  end

  describe "#add_rate" do
    it "creates a rate in the database" do
      expect { store.add_rate("EUR", "USD", 1.5) }
        .to change(ActiveCurrency::Rate, :count).by(1)

      rate = ActiveCurrency::Rate.last
      expect(rate.from).to eq("EUR")
      expect(rate.to).to eq("USD")
      expect(rate.value).to eq(1.5)
      expect(rate.created_at).to eq(Time.zone.now)
    end

    it "deletes the cache key" do
      store.add_rate("EUR", "USD", 1.5)

      expect(Rails.cache)
        .to have_received("delete")
        .with(%w[active_currency_rate EUR USD])
    end

    context "with a date" do
      let(:date) { 1.day.ago }

      it "assigns it to the currency_rate" do
        store.add_rate("EUR", "USD", 1.5, date)

        rate = ActiveCurrency::Rate.last
        expect(rate.created_at).to eq(date)
      end
    end
  end

  describe "#marshal_dump" do
    it "dumps the class so the store can be rebuilt on load" do
      expect(store.marshal_dump).to eq([described_class])
    end

    it "lets a bank backed by the store round-trip through Marshal" do
      bank = Money::Bank::VariableExchange.new(store)

      loaded = Marshal.load(Marshal.dump(bank))

      expect(loaded.store).to be_a(described_class)
    end
  end
end
