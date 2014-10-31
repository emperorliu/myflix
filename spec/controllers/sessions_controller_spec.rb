require 'spec_helper'

describe SessionsController do
  describe "GET new" do
    it "renders the new template for unauthenticated users" do
      get :new
      expect(response).to render_template :new
    end
    it "redirects to home path for authenticated users" do
      session[:user_id] = Fabricate(:user).id
      get :new
      expect(response).to redirect_to home_path
    end
  end

  describe "POST create" do
    context "with valid credentials" do
      let(:jeff) { Fabricate(:user) }
      before do
        post :create, { email: jeff.email, password: jeff.password }
      end

      it "puts the signed in user in the session" do
        expect(session[:user_id]).to eq(jeff.id)
      end

      it "redirect to home page" do
        expect(response).to redirect_to home_path
      end

      it "sets a flash sucess" do
        expect(flash[:success]).not_to be_blank
      end
    end

    context "with invalid credentials" do
      let(:jeff) { Fabricate(:user) }
      before do
        post :create, { email: jeff.email, password: jeff.password + "asdf" }
      end
      
      it "does not put the signed user in the session" do
        expect(session[:user_id]).to be_nil
      end

      it "redirects to sign in path" do
        expect(response).to redirect_to sign_in_path
      end

      it "sets an error message - flash danger" do
        expect(flash[:danger]).not_to be_blank
      end
    end
  end

  describe "GET destroy" do
    before do
      session[:user_id] = Fabricate(:user).id
      get :destroy
    end

    it "clears the session" do
      expect(session[:user_id]).to be_nil
    end

    it "redirects to the root path" do
      expect(response).to redirect_to root_path
    end

    it "sets the flash danger notice" do
      expect(flash[:danger]).not_to be_blank
    end
  end
end