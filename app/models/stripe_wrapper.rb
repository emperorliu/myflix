module StripeWrapper
  class Charge
    attr_reader :charge, :status

    def initialize(charge, status)
      @charge = charge
      @status = status
    end

    def self.create(options={})
      StripeWrapper.set_api_key
      begin
        charge = Stripe::Charge.create(
          amount: options[:amount],
          currency: 'usd',
          card: options[:card],
          description: options[:description]
        )
        new(charge, :success)
      rescue Stripe::CardError => e
        new(e, :error)
      end
    end

    def successful?
      status == :success
    end

    def error_message
      charge.message
    end
  end

  def self.set_api_key
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
  end
end