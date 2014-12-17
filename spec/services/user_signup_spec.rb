require 'spec_helper'

describe UserSignup do
  describe "#sign_up" do
    context "valid personal info and valid card" do

      before do
        charge = double(:charge, successful?: true)
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        ActionMailer::Base.deliveries.clear
        # create is trying to hit Stripe server, but didn't set up vcr for specs. stubbing because this whole process is already tested in StripeWrapper. trusting that StripeWrapper charge will do the right thing, so won't integrate with controller test.
        # stub has no 100% expectation the method was called, so we use should_receive
      end

      it "creates a user" do
        UserSignup.new(Fabricate.build(:user)).sign_up("some_stripe_token", nil)
        # .new gets an instance of the class, http requests get a hash
        expect(User.count).to eq(1)
      end

      it "makes the user follow the inviter" do
        jeff = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: jeff, recipient_email: 'sean@gmail.com')
        UserSignup.new(Fabricate.build(:user, { email: 'sean@gmail.com', password: 'password', full_name: 'Sean' })).sign_up("some_stripe_token", invitation.token)
        # post :create, user: { email: 'sean@gmail.com', password: 'password', full_name: 'Sean' }, invitation_token: invitation.token
        sean = User.where(email: 'sean@gmail.com').first
        expect(sean.follows?(jeff)).to be true
      end

      it "makes the inviter follow the user" do
        jeff = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: jeff, recipient_email: 'sean@gmail.com')
        UserSignup.new(Fabricate.build(:user, { email: 'sean@gmail.com', password: 'password', full_name: 'Sean' })).sign_up("some_stripe_token", invitation.token)
        sean = User.where(email: 'sean@gmail.com').first
        expect(jeff.follows?(sean)).to be true
      end

      it "expires the invitation upon acceptance" do
        jeff = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: jeff, recipient_email: 'sean@gmail.com')
        UserSignup.new(Fabricate.build(:user, { email: 'sean@gmail.com', password: 'password', full_name: 'Sean' })).sign_up("some_stripe_token", invitation.token)
        expect(Invitation.first.token).to be_nil
      end

      it "sends out the email with valid inputs" do
        UserSignup.new(Fabricate.build(:user, { email: 'jeff@example.com', password: 'password', full_name: 'Jeff' })).sign_up("some_stripe_token", nil)
        expect(ActionMailer::Base.deliveries.last.to).to eq(["jeff@example.com"]) 
      end

      it "sends out email with the user's name with valid inputs" do
        UserSignup.new(Fabricate.build(:user, { email: 'jeff@example.com', password: 'password', full_name: 'Jeff Liu' })).sign_up("some_stripe_token", nil)
        expect(ActionMailer::Base.deliveries.last.body).to include("Jeff Liu")
      end
    end

    context "valid personal info and declined card" do
      before do
        charge = double(:charge, successful?: false, error_message: "Your card was declined.")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        UserSignup.new(Fabricate.build(:user)).sign_up('1231231', nil)
      end

      it "does not create a new user record" do
        expect(User.count).to eq(0)
      end
    end

    context "with invalid input" do

      it "does not create a user" do
        UserSignup.new(User.new(password: "password", full_name: "jeff")).sign_up('1231231', nil)
        expect(User.count).to eq(0)
      end

      it "does not charge the card" do
        StripeWrapper::Charge.should_not_receive(:create)
        UserSignup.new(User.new(password: "password", full_name: "jeff")).sign_up('1231231', nil)
      end

      it "does not send out email with invalid inputs" do
        ActionMailer::Base.deliveries.clear
        UserSignup.new(User.new(password: "password", full_name: "jeff")).sign_up('1231231', nil)
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end
end