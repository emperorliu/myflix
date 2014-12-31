require 'spec_helper'

describe "Deactivate user on failed charge" do
  let(:event_data) do
    {
      "id"=> "evt_15FXDOJGSn3Q2fvTMge3DUPi",
      "created"=> 1419973662,
      "livemode"=> false,
      "type"=> "charge.failed",
      "data"=> {
        "object"=> {
          "id"=> "ch_15FXDNJGSn3Q2fvTk2sDcUbW",
          "object"=> "charge",
          "created"=> 1419973661,
          "livemode"=> false,
          "paid"=> false,
          "amount"=> 999,
          "currency"=> "usd",
          "refunded"=> false,
          "captured"=> false,
          "card"=> {
            "id"=> "card_15FXCfJGSn3Q2fvTrNDWXbRk",
            "object"=> "card",
            "last4"=> "0341",
            "brand"=> "Visa",
            "funding"=> "credit",
            "exp_month"=> 12,
            "exp_year"=> 2017,
            "fingerprint"=> "SFLzr3JECQVUw4ib",
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
            "customer"=> "cus_5Q7Ca2btVc9cfH"
          },
          "balance_transaction"=> nil,
          "failure_message"=> "Your card was declined.",
          "failure_code"=> "card_declined",
          "amount_refunded"=> 0,
          "customer"=> "cus_5Q7Ca2btVc9cfH",
          "invoice"=> nil,
          "description"=> "payment",
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
            "url"=> "/v1/charges/ch_15FXDNJGSn3Q2fvTk2sDcUbW/refunds",
            "data"=> []
          },
          "statement_description"=> nil
        }
      },
      "object"=> "event",
      "pending_webhooks"=> 1,
      "request"=> "iar_5QNzBqtHhYsOnP",
      "api_version"=> "2014-11-20"
    }
  end

  it "deactivates a user with the web hook data from stripe for charge failed", :vcr do
    jeff = Fabricate(:user, customer_token: "cus_5Q7Ca2btVc9cfH")
    post "/stripe_events", event_data
    expect(jeff.reload).not_to be_active
  end
end