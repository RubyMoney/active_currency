# frozen_string_literal: true

require "spec_helper"
require "eu_central_bank"

RSpec.describe ActiveCurrency::AddRates do
  let(:currencies) { %w[EUR USD CAD] }

  shared_examples "with a mocked EuCentralBank" do
    # Mock bank
    let(:bank) { instance_double EuCentralBank, update_rates: nil }
    before do
      allow(EuCentralBank).to receive(:new) { bank }
      allow(bank).to receive(:get_rate).with("EUR", "USD").and_return(1.42)
      allow(bank).to receive(:get_rate).with("USD", "EUR").and_return(nil)
      allow(bank).to receive(:get_rate).with("EUR", "CAD").and_return(1.12)
      allow(bank).to receive(:get_rate).with("CAD", "EUR").and_return(nil)
      allow(bank).to receive(:get_rate).with("CAD", "USD").and_return(nil)
      allow(bank).to receive(:get_rate).with("USD", "CAD").and_return(nil)
    end

    it "updates the rates" do
      add_rate

      expect(bank).to have_received(:update_rates)
    end
  end

  shared_examples "with a custom bank" do
    # Mock bank
    let(:bank) { double :bank, update_rates: nil }

    before do
      allow(bank).to receive(:get_rate).with("EUR", "USD").and_return(1.42)
      allow(bank).to receive(:get_rate).with("USD", "EUR") { 1 / 1.42 }
      allow(bank).to receive(:get_rate).with("EUR", "CAD").and_return(1.12)
      allow(bank).to receive(:get_rate).with("CAD", "EUR") { 1 / 1.12 }
      allow(bank).to receive(:get_rate).with("CAD", "USD").and_return(nil)
      allow(bank).to receive(:get_rate).with("USD", "CAD").and_return(nil)
    end

    it "updates the rates" do
      add_rate

      expect(bank).to have_received(:update_rates)
    end
  end

  shared_examples "sets the rates" do
    # Mock store
    let(:store) { instance_double ActiveCurrency::RateStore, add_rate: nil }
    before do
      allow(ActiveCurrency::RateStore).to receive(:new) { store }
    end

    it "calls add_rate with the correct arguments" do
      add_rate

      expect(store).to have_received(:add_rate).exactly(6).times
      expect(store).to have_received(:add_rate).with("EUR", "USD", 1.42)
      expect(store).to have_received(:add_rate).with("USD", "EUR", 1 / 1.42)
      expect(store).to have_received(:add_rate).with("EUR", "CAD", 1.12)
      expect(store).to have_received(:add_rate).with("CAD", "EUR", 1 / 1.12)
      expect(store)
        .to have_received(:add_rate)
        .with("CAD", "USD", a_value_within(0.0000001).of(1.42 / 1.12))
      expect(store)
        .to have_received(:add_rate)
        .with("USD", "CAD", a_value_within(0.0000001).of(1.12 / 1.42))
    end
  end

  describe ".call" do
    let(:add_rate) { described_class.call(currencies: currencies) }

    context "with the default bank" do
      include_examples "with a mocked EuCentralBank"
      include_examples "sets the rates"
    end

    context "when given a custom bank" do
      let(:add_rate) do
        described_class.call(currencies: currencies, bank: bank)
      end

      include_examples "with a custom bank"
      include_examples "sets the rates"
    end

    context "when given a variety of currency formats" do
      let(:currencies) { ["eur", :USD, Money::Currency.new("CAD")] }

      include_examples "with a mocked EuCentralBank"
      include_examples "sets the rates"
    end

    context "with the deprecated array first currency" do
      let(:add_rate) { described_class.call(currencies) }

      context "with the default bank" do
        include_examples "with a mocked EuCentralBank"
        include_examples "sets the rates"
      end

      context "when given a custom bank" do
        let(:add_rate) do
          described_class.call(currencies, bank: bank)
        end

        include_examples "with a custom bank"
        include_examples "sets the rates"
      end
    end

    context "with a custom multiplier" do
      # Mock store
      let(:store) { instance_double ActiveCurrency::RateStore, add_rate: nil }

      let(:multiplier) do
        {
          %w[USD EUR] => 1.1,
          %w[CAD EUR] => 1.2,
        }
      end

      before do
        allow(ActiveCurrency.configuration)
          .to receive(:multiplier)
          .and_return(multiplier)

        allow(ActiveCurrency::RateStore).to receive(:new) { store }
      end

      include_examples "with a mocked EuCentralBank"

      it "calls add_rate with increased values" do
        add_rate

        expect(store).to have_received(:add_rate).exactly(6).times

        expect(store)
          .to have_received(:add_rate)
          .with("EUR", "USD", 1.42)
        expect(store)
          .to have_received(:add_rate)
          .with("USD", "EUR", (1 / 1.42) * 1.1)
        expect(store)
          .to have_received(:add_rate)
          .with("EUR", "CAD", 1.12)
        expect(store)
          .to have_received(:add_rate)
          .with("CAD", "EUR", (1 / 1.12) * 1.2)
        expect(store)
          .to have_received(:add_rate)
          .with("CAD", "USD", a_value_within(0.0000001).of(1.42 / 1.12))
        expect(store)
          .to have_received(:add_rate)
          .with("USD", "CAD", a_value_within(0.0000001).of(1.12 / 1.42))
      end
    end
  end
end
