module StripeWrapper
  class Charge
    attr_reader :charge, :status

    def initialize(charge, status)
      @charge = charge
      @status = status
    end

    def self.create(options={})
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

  class Customer
    attr_reader :customer, :status

    def initialize(customer, status)
      @customer = customer
      @status = status
    end
    def self.create(options={})
      begin
        customer = Stripe::Customer.create(
          card: options[:card],
          email: options[:user].email,
          plan: "basicplanid"
          )
        new(customer, :success)
      rescue Stripe::CardError => e
        new(e, :error)
      end
    end

    def successful?
      status == :success
    end

    def error_message
      customer.message
    end
  end
end