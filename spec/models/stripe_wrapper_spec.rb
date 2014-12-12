require 'spec_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge do
    describe "#create" do
      it "makes a successful charge", :vcr do
        Stripe.api_key = ENV['STRIPE_SECRET_KEY']
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
          :currency => "usd",
          :card => token,
          :description => "Charge for test@example.com"
        )
        expect(response.charge.amount). to eq(999)
        expect(response.charge.currency).to eq('usd')
      end
    end
  end
end