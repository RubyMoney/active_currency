# frozen_string_literal: true

require "spec_helper"
require "eu_central_bank"

RSpec.describe ActiveCurrency::AddRates do
  let(:currencies) { %w[EUR USD CAD] }

  describe ".call" do
    let(:add_rate) { described_class.call(currencies: currencies) }

    # Mock store and bank
    let(:store) { instance_double ActiveCurrency::RateStore, add_rate: nil }
    let(:bank) do
      instance_double EuCentralBank, update_rates: nil, get_rate: nil
    end

    before do
      allow(ActiveCurrency::RateStore).to receive(:new).and_return(store)
      allow(EuCentralBank).to receive(:new).and_return(bank)
    end

    context "with the default bank" do
      before do
        allow(bank).to receive(:get_rate).with("EUR", "USD").and_return(1.42)
        allow(bank).to receive(:get_rate).with("EUR", "CAD").and_return(1.12)
      end

      it "calls add_rate with the correct arguments" do
        add_rate

        expect(bank).to have_received(:update_rates)
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

    context "when given a custom bank" do
      let(:add_rate) do
        described_class.call(currencies: currencies, bank: bank_b)
      end

      let(:bank_b) do
        instance_double EuCentralBank, update_rates: nil, get_rate: nil
      end

      before do
        allow(bank_b).to receive(:get_rate).with("EUR", "USD").and_return(1.42)
        allow(bank_b).to receive(:get_rate).with("EUR", "CAD").and_return(1.12)
      end

      it "calls add_rate with the correct arguments" do
        add_rate

        expect(EuCentralBank).not_to have_received(:new)

        expect(bank_b).to have_received(:update_rates)
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

    context "when given a variety of currency formats" do
      let(:add_rate) do
        described_class.call(
          currencies: ["eur", :USD, Money::Currency.new("CAD")],
        )
      end

      before do
        allow(bank).to receive(:get_rate).with("EUR", "USD").and_return(1.42)
        allow(bank).to receive(:get_rate).with("EUR", "CAD").and_return(1.12)
      end

      it "calls add_rate with the correct arguments" do
        add_rate

        expect(bank).to have_received(:update_rates)
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

    context "with the deprecated array first currency" do
      let(:add_rate) { described_class.call(currencies) }

      context "with the default bank" do
        before do
          allow(bank).to receive(:get_rate).with("EUR", "USD").and_return(1.42)
          allow(bank).to receive(:get_rate).with("EUR", "CAD").and_return(1.12)
        end

        it "calls add_rate with the correct arguments" do
          add_rate

          expect(bank).to have_received(:update_rates)
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

      context "when given a custom bank" do
        let(:add_rate) { described_class.call(currencies, bank: bank_b) }
        let(:bank_b) { double :bank, update_rates: nil, get_rate: nil }

        before do
          allow(bank_b).to receive(:get_rate).with("EUR", "USD").and_return(1.42)
          allow(bank_b).to receive(:get_rate).with("USD", "EUR") { 1 / 1.42 }
          allow(bank_b).to receive(:get_rate).with("EUR", "CAD").and_return(1.12)
          allow(bank_b).to receive(:get_rate).with("CAD", "EUR") { 1 / 1.12 }
          allow(ActiveCurrency::RateStore).to receive(:new) { store }
          allow(ActiveCurrency::RateStore).to receive(:new) { store }
        end

        it "calls add_rate with the correct arguments" do
          add_rate

          expect(bank_b).to have_received(:update_rates)
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
    end

    context "with a custom multiplier" do
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

        allow(bank).to receive(:get_rate).with("EUR", "USD").and_return(1.42)
        allow(bank).to receive(:get_rate).with("EUR", "CAD").and_return(1.12)
      end

      it "calls add_rate with increased values" do
        add_rate

        expect(bank).to have_received(:update_rates)
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
