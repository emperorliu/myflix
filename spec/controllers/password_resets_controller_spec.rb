require 'spec_helper'

describe PasswordResetsController do
  describe "GET show" do

    it "renders show template if the token is valid" do
      jeff = Fabricate(:user)
      jeff.update_column(:token, '12345')
      get :show, id: '12345'
      expect(response).to render_template :show
    end

    it "sets @token" do
      jeff = Fabricate(:user)
      jeff.update_column(:token, '12345')
      get :show, id: '12345'
      expect(assigns(:token)).to eq('12345')
    end

    it "redirects to the expired token page if the token is not valid" do
      jeff = Fabricate(:user, token: '12345')
      get :show, id: '23456'
      expect(response).to redirect_to expired_token_path
    end
  end

  describe "POST create" do

    context "with valid token" do
      it "should update the user's password" do
        jeff = Fabricate(:user, password: "old")
        jeff.update_column(:token, '12345')
        post :create, { password: "hey", token: "12345" }
        expect(jeff.reload.authenticate("hey")).to eq(jeff)
      end

      it "should redirect to the sign in page" do
        jeff = Fabricate(:user, password: "old")
        jeff.update_column(:token, '12345')
        post :create, { password: "hey", token: "12345" }   
        expect(response).to redirect_to sign_in_path   
      end

      it "sets the flash success message" do
        jeff = Fabricate(:user, password: "old")
        jeff.update_column(:token, '12345')
        post :create, { password: "hey", token: "12345" }   
        expect(flash[:success]).to be_present 
      end

      it "regenerates the user token" do
        jeff = Fabricate(:user, password: "old")
        jeff.update_column(:token, '12345')
        post :create, { password: "hey", token: "12345" }
        expect(jeff.reload.token).not_to eq('12345')
      end
      #we want to reduce risk of someone else obtaining token and changing pw, so we need someone to make this short-lived
    end

    context "with invalid token" do
      it "redirects to the expired token path" do
        jeff = Fabricate(:user, password: "old")
        jeff.update_column(:token, '12345')
        post :create, { token: '23456', password: "hey" }
        expect(response).to redirect_to expired_token_path
      end
    end
    #this is for people who try to inspect element on the reset pw page and try to update pw for someone else by changing the token
  end
end