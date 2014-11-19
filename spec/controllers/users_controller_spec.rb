require 'spec_helper'

describe UsersController do

  describe "GET new" do
    it "sets @user" do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe "POST create" do
    context "with valid input" do
      before do
        post :create, user: Fabricate.attributes_for(:user)
      end

      it "creates a user" do
        expect(User.count).to eq(1)
      end

      it "redirect to sign in path" do
        expect(response).to redirect_to sign_in_path
      end
    end

    context "with invalid input" do
      before do        
        post :create, user: { password: "password", full_name: "jeff" }
      end 

      it "does not create a user" do
        expect(User.count).to eq(0)
      end

      it "renders the :new template" do
        expect(response).to render_template :new
      end

      it "sets @user" do
        expect(assigns[:user]).to be_instance_of(User)
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
end