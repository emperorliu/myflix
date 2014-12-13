require 'spec_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge do
    describe "#create" do
      it "makes a successful charge", :vcr do
        token = Stripe::Token.create(
          :card => {
            :number => "4242424242424242",
            :exp_month => 12,
            :exp_year => 2019,
            :cvc => "314"
          },
        ).id
        response = StripeWrapper::Charge.create(
          :amount => 999,
          :card => token,
          :description => "Charge for test@example.com"
        )
        expect(response.charge.amount). to eq(999)
        expect(response.charge.currency).to eq('usd')
      end

      it "makes a card declined charge", :vcr do
        token = Stripe::Token.create(
          :card => {
            :number => "4000000000000119",
            :exp_month => 12,
            :exp_year => 2019,
            :cvc => "314"
          },
        ).id
        response = StripeWrapper::Charge.create(
          :amount => 999,
          :card => token,
          :description => "An invalid charge."
        )
        expect(response.status).to eq(:error)
      end

      it "returns error_message for declined cards", :vcr do
        token = Stripe::Token.create(
          :card => {
            :number => "4000000000000119",
            :exp_month => 12,
            :exp_year => 2019,
            :cvc => "314"
          },
        ).id
        response = StripeWrapper::Charge.create(
          :amount => 999,
          :card => token,
          :description => "An invalid charge."
        )
        expect(response.error_message).to eq("An error occurred while processing your card. Try again in a little bit.")
      end
    end
  end
end