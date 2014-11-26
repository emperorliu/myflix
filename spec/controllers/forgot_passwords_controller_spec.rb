require 'spec_helper'

describe ForgotPasswordsController do
  describe "POST create" do

    context "with blank inputs" do

      it "redirects to the forgot passwords page" do
        post :create, email: ""
        expect(response).to redirect_to forgot_password_path
      end

      it "shows an error message" do
        post :create, email: ""
        expect(flash[:danger]). to eq("Email cannot be blank.")
      end
    end

    context "with existing email" do

      it "should redirect to the password confirmation page" do
        Fabricate(:user, email: "jeff@example.com")
        post :create, email: "jeff@example.com"
        expect(response).to redirect_to forgot_password_confirmation_path
      end

      it "should send out an email to the email address" do
        Fabricate(:user, email: "jeff@example.com")
        post :create, email: "jeff@example.com"
        expect(ActionMailer::Base.deliveries.last.to).to eq(["jeff@example.com"])
      end
    end

    context "with non-existing emails" do
      
      it "should redirect to the forgot passwords page" do
        Fabricate(:user, email: "jeff@example.com")
        post :create, email: "foo@example.com"
        expect(response).to redirect_to forgot_password_path
      end

      it "shows an error message" do
        Fabricate(:user, email: "jeff@example.com")
        post :create, email: "foo@example.com"
        expect(flash[:danger]).to eq("There is no user with that email in the system.")
      end
    end
  end
end