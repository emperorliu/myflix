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

    context "sending emails" do

      after { ActionMailer::Base.deliveries.clear }
      #emails don't rollback so it just keeps adding with each test. have to clear after each test, hence the "after"

      it "sends out the email with valid inputs" do
        post :create, user: { email: "jeff@example.com", password: "password", full_name: "jeff" }
        expect(ActionMailer::Base.deliveries.last.to).to eq(["jeff@example.com"]) 
      end

      it "sends out email with the user's name with valid inputs" do
        post :create, user: { email: "jeff@example.com", password: "password", full_name: "jeff" }
        expect(ActionMailer::Base.deliveries.last.body).to include("jeff")
      end

      it "does not send out email with invalid inputs" do
        post :create, user: { email: "jeff@example.com" }
        expect(ActionMailer::Base.deliveries).to be_empty
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