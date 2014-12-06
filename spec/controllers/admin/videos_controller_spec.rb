require 'spec_helper'

describe Admin::VideosController do
  describe "GET new" do
    it_behaves_like "requires sign in" do
      let(:action) { get :new }
    end

    it_behaves_like "requires admin" do
      let(:action) { get :new }
    end

    it "sets the @video to a new video" do
      set_current_admin
      get :new
      expect(assigns(:video)).to be_a_new(Video)
    end

    it "sets the flash error message for regular user" do
      set_current_user
      get :new
      expect(flash[:danger]).to be_present
    end
  end

  describe "POST create" do
    it_behaves_like "requires sign in" do
      let(:action) { post :create }
    end

    it_behaves_like "requires admin" do
      let(:action) { post :create }
    end

    context "with valid input" do

      it "redirects to the add new video page" do
        set_current_admin
        comedies = Fabricate(:category)
        reality = Fabricate(:category)
        post :create, video: { title: "TRL", category_ids: [comedies.id, reality.id], description: "good show" }
        expect(response).to redirect_to new_admin_video_path
      end

      it "creates a video" do
        set_current_admin
        comedies = Category.create(name: "comedies")
        reality = Category.create(name: "reality")
        post :create, video: { title: "TRL", category_ids: [comedies.id, reality.id], description: "good show" }
        expect(comedies.videos.count).to eq(1)
        expect(reality.videos.count).to eq(1)
      end

      it "sets a flash success messages" do
        set_current_admin
        comedies = Category.create(name: "comedies")
        reality = Category.create(name: "reality")
        post :create, video: { title: "TRL", category_ids: [comedies.id, reality.id], description: "good show" }
        expect(flash[:success]).to be_present
      end
    end

    context "with invalid input" do

      it "does not create a video" do
        set_current_admin
        comedies = Category.create(name: "comedies")
        reality = Category.create(name: "reality")
        post :create, video: { title: "TRL", description: "good show" }
        expect(comedies.videos.count).to eq(0)
        expect(reality.videos.count).to eq(0)
      end

      it "renders the new template" do
        set_current_admin
        comedies = Category.create(name: "comedies")
        reality = Category.create(name: "reality")
        post :create, video: { title: "TRL", description: "good show" }
        expect(response).to render_template :new
      end

      it "sets the @video variable" do
        set_current_admin
        comedies = Category.create(name: "comedies")
        reality = Category.create(name: "reality")
        post :create, video: { title: "TRL", description: "good show" }
        expect(:video).not_to be_nil
      end

      it "sets a flash danger message" do
        set_current_admin
        comedies = Category.create(name: "comedies")
        reality = Category.create(name: "reality")
        post :create, video: { title: "TRL", description: "good show" }
        expect(flash[:danger]).to be_present
      end
    end
  end
end