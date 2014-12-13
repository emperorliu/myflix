require 'spec_helper'

describe UsersController do

  describe "GET new" do
    it "sets @user" do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe "POST create" do
    context "with valid personal info & valid card" do
      before do
        charge = double(:charge, successful?: true)
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        # create is trying to hit Stripe server, but didn't set up vcr for specs. stubbing because this whole process is already tested in StripeWrapper. trusting that StripeWrapper charge will do the right thing, so won't integrate with controller test.
        # stub has no 100% expectation the method was called, so we use should_receive
      end

      it "creates a user" do
        post :create, user: Fabricate.attributes_for(:user)
        expect(User.count).to eq(1)
      end

      it "redirect to sign in path" do
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to sign_in_path
      end

      it "makes the user follow the inviter" do
        jeff = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: jeff, recipient_email: 'sean@gmail.com')
        post :create, user: { email: 'sean@gmail.com', password: 'password', full_name: 'Sean' }, invitation_token: invitation.token
        sean = User.where(email: 'sean@gmail.com').first
        expect(sean.follows?(jeff)).to be true
      end

      it "makes the inviter follow the user" do
        jeff = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: jeff, recipient_email: 'sean@gmail.com')
        post :create, user: { email: 'sean@gmail.com', password: 'password', full_name: 'Sean' }, invitation_token: invitation.token
        sean = User.where(email: 'sean@gmail.com').first
        expect(jeff.follows?(sean)).to be true
      end

      it "expires the invitation upon acceptance" do
        jeff = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: jeff, recipient_email: 'sean@gmail.com')
        post :create, user: { email: 'sean@gmail.com', password: 'password', full_name: 'Sean' }, invitation_token: invitation.token
        expect(Invitation.first.token).to be_nil
      end
    end

    context "with invalid input" do

      it "does not create a user" do
        post :create, user: { password: "password", full_name: "jeff" }
        expect(User.count).to eq(0)
      end

      it "renders the :new template" do
        post :create, user: { password: "password", full_name: "jeff" }
        expect(response).to render_template :new
      end

      it "sets @user" do
        post :create, user: { password: "password", full_name: "jeff" }
        expect(assigns[:user]).to be_instance_of(User)
      end

      it "does not charge the card" do
        StripeWrapper::Charge.should_not_receive(:create)
        post :create, user: { password: "password", full_name: "jeff" }
      end

      it "does not send out email with invalid inputs" do
        ActionMailer::Base.deliveries.clear
        post :create, user: { email: "jeff@example.com" }
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "valid personal info and declined card" do
      before do
        charge = double(:charge, successful?: false, error_message: "Your card was declined.")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231241'
      end

      it "does not create a new user record" do
        expect(User.count).to eq(0)
      end

      it "renders the new template" do
        expect(response).to render_template :new
      end

      it "sets the flash error message" do
        expect(flash[:danger]).to eq("Your card was declined.")
      end
    end

    context "sending emails" do

      before do
        charge = double('charge', successful?: true)
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        ActionMailer::Base.deliveries.clear
      end

      it "sends out the email with valid inputs" do
        post :create, user: { email: "jeff@example.com", password: "password", full_name: "jeff" }
        expect(ActionMailer::Base.deliveries.last.to).to eq(["jeff@example.com"]) 
      end

      it "sends out email with the user's name with valid inputs" do
        post :create, user: { email: "jeff@example.com", password: "password", full_name: "jeff" }
        expect(ActionMailer::Base.deliveries.last.body).to include("jeff")
      end
    end
  end

  describe "GET show" do
    it_behaves_like "requires sign in" do
      let(:action) { get :show, id: 3 }
    end

    it "sets @user" do
      set_current_user
      jeff = Fabricate(:user)
      get :show, id: jeff.id
      expect(assigns(:user)).to eq(jeff)
    end
  end

  describe "GET new_with_invitation_token" do

    it "renders the new template" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(response).to render_template :new
    end

    it "sets @user with recipient's email" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:user).email).to eq(invitation.recipient_email)
    end

    it "sets @invitation_token" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:invitation_token)).to eq(invitation.token)
    end

    it "redirects to expired token page for invalid inputs" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: "12345"
      expect(response).to redirect_to expired_token_path
    end
  end
end