require 'spec_helper'

describe StripeWrapper do
  let(:valid_token) do
    token = Stripe::Token.create(
      :card => {
        :number => "4242424242424242",
        :exp_month => 12,
        :exp_year => 2019,
        :cvc => "314"
      },
    ).id
  end
  let(:declined_token) do
    token = Stripe::Token.create(
      :card => {
        :number => "4000000000000119",
        :exp_month => 12,
        :exp_year => 2019,
        :cvc => "314"
      },
    ).id
  end
  describe StripeWrapper::Charge do
    describe "#create" do
      it "makes a successful charge", :vcr do
        response = StripeWrapper::Charge.create(
          :amount => 999,
          :card => valid_token,
          :description => "Charge for test@example.com"
        )
        expect(response.charge.amount). to eq(999)
        expect(response.charge.currency).to eq('usd')
      end

      it "makes a card declined charge", :vcr do
        response = StripeWrapper::Charge.create(
          :amount => 999,
          :card => declined_token,
          :description => "An invalid charge."
        )
        expect(response.status).to eq(:error)
      end

      it "returns error_message for declined cards", :vcr do
        response = StripeWrapper::Charge.create(
          :amount => 999,
          :card => declined_token,
          :description => "An invalid charge."
        )
        expect(response.error_message).to eq("An error occurred while processing your card. Try again in a little bit.")
      end
    end
  end

  describe StripeWrapper::Customer do
    describe ".create" do
      it "creates a customer with a successful card", :vcr do
        jeff = Fabricate(:user)
        response = StripeWrapper::Customer.create(
          user: jeff,
          card: valid_token
          )
        expect(response).to be_successful
      end

      it "does not create a customer with a declined card", :vcr do
        jeff = Fabricate(:user)
        response = StripeWrapper::Customer.create(
          user: jeff,
          card: declined_token
          )
        expect(response).not_to be_successful
      end

      it "returns the error message for declined card", :vcr do
        jeff = Fabricate(:user)
        response = StripeWrapper::Customer.create(
          user: jeff,
          card: declined_token
          )
        expect(response.error_message).to eq("An error occurred while processing your card. Try again in a little bit.")
      end

      it "returns the customer token for a valid card", :vcr do
        jeff = Fabricate(:user)
        response = StripeWrapper::Customer.create(
          user: jeff,
          card: valid_token
          )
        expect(response.customer_token).to be_present
      end
    end
  end
end