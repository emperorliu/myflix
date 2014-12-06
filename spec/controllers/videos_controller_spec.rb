require 'spec_helper'

describe VideosController do
  describe "GET show" do
    context "with authenticated users" do
      before { set_current_user }

      it "sets @video variable" do
        video = Fabricate(:video)
        get :show, id: video.id
        expect(assigns(:video)).to eq(video)
      end

      it "sets @reviews" do
        video = Fabricate(:video)
        review1 = Fabricate(:review, video: video)
        review2 = Fabricate(:review, video: video)
        get :show, id: video.id
        expect(assigns(:reviews)).to match_array([review1, review2])
      end

    end

    context "with unauthenticated users" do
      it "redirects the user to sign_in page" do
        video = Fabricate(:video)
        get :show, id: video.id
        expect(response).to redirect_to sign_in_path
      end
    end
  end

  describe "GET watch" do

    let(:video) { Fabricate(:video) }

    it "sets the @video variable to that particular video" do
      get :watch, id: video.id
      expect(assigns(:video)).to eq(video)
    end

    it_behaves_like "requires sign in" do
      let(:action) { get :watch, id: video.id }
    end
  end

  describe "GET search" do
    it "sets @results for authenticated users" do
      set_current_user
      futurama = Fabricate(:video, title: "Futurama")
      get :search, search_term: "rama"
      expect(assigns(:results)).to eq([futurama])
    end

    it "redirects to sign in page for the unauthenticated users" do
      futurama = Fabricate(:video, title: "Futurama")
      get :search, search_term: "rama"
      expect(response).to redirect_to sign_in_path
    end
  end
end