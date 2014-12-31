require 'spec_helper'

describe "Create Payment On Successful Charge" do
  let(:event_data) do
    {
      "id"=> "evt_15DD5JJGSn3Q2fvTsf7K7pfQ",
      "created"=> 1419419625,
      "livemode"=> false,
      "type"=> "charge.succeeded",
      "data"=> {
        "object"=> {
          "id"=> "ch_15DD5IJGSn3Q2fvTbWIDG6CK",
          "object"=> "charge",
          "created"=> 1419419624,
          "livemode"=> false,
          "paid"=> true,
          "amount"=> 999,
          "currency"=> "usd",
          "refunded"=> false,
          "captured"=> true,
          "card"=> {
            "id"=> "card_15DD5IJGSn3Q2fvTa6kqY1o8",
            "object"=> "card",
            "last4"=> "4242",
            "brand"=> "Visa",
            "funding"=> "credit",
            "exp_month"=> 12,
            "exp_year"=> 2017,
            "fingerprint"=> "rNhPRcdSCrZC1EIl",
            "country"=> "US",
            "name"=> nil,
            "address_line1"=> nil,
            "address_line2"=> nil,
            "address_city"=> nil,
            "address_state"=> nil,
            "address_zip"=> nil,
            "address_country"=> nil,
            "cvc_check"=> "pass",
            "address_line1_check"=> nil,
            "address_zip_check"=> nil,
            "dynamic_last4"=> nil,
            "customer"=> "cus_5Nz385NW0Ks0Gg"
          },
          "balance_transaction"=> "txn_15DD5IJGSn3Q2fvTXRyMdjGj",
          "failure_message"=> nil,
          "failure_code"=> nil,
          "amount_refunded"=> 0,
          "customer"=> "cus_5Nz385NW0Ks0Gg",
          "invoice"=> "in_15DD5IJGSn3Q2fvTYESb92ce",
          "description"=> nil,
          "dispute"=> nil,
          "metadata"=> {},
          "statement_descriptor"=> nil,
          "fraud_details"=> {},
          "receipt_email"=> nil,
          "receipt_number"=> nil,
          "shipping"=> nil,
          "refunds"=> {
            "object"=> "list",
            "total_count"=> 0,
            "has_more"=> false,
            "url"=> "/v1/charges/ch_15DD5IJGSn3Q2fvTbWIDG6CK/refunds",
            "data"=> []
          },
          "statement_description"=> nil
        }
      },
      "object"=> "event",
      "pending_webhooks"=> 1,
      "request"=> "iar_5Nz3t2bq9aE3x7",
      "api_version"=> "2014-11-20"
    }
  end
  it "creates a payment with the webhook from stripe for charge succeeded", :vcr do
    post "/stripe_events", event_data
    expect(Payment.count).to eq(1)
  end

  it "creates the payment associated with the user", :vcr do
    jeff = Fabricate(:user, customer_token: "cus_5Nz385NW0Ks0Gg")
    post "/stripe_events", event_data
    expect(Payment.first.user).to eq(jeff)
  end

  it "creates the payment with the amount", :vcr do
    jeff = Fabricate(:user, customer_token: "cus_5Nz385NW0Ks0Gg")
    post "/stripe_events", event_data
    expect(Payment.first.amount).to eq(999)
  end

  it "creates the payment with reference id", :vcr do
    jeff = Fabricate(:user, customer_token: "cus_5Nz385NW0Ks0Gg")
    post "/stripe_events", event_data
    expect(Payment.first.reference_id).to eq("ch_15DD5IJGSn3Q2fvTbWIDG6CK")
  end
end