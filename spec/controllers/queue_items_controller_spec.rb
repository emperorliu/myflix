require 'spec_helper'

describe QueueItemsController do
  describe "GET index" do

    it "sets @queue_items to queue items of the logged in user" do
      jeff = Fabricate(:user)
      session[:user_id] = jeff.id
      queue_item1 = Fabricate(:queue_item, user: jeff)
      queue_item2 = Fabricate(:queue_item, user: jeff)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end

    it "redirects to the sign in page for unauthenticated users" do
      get :index
      expect(response).to redirect_to sign_in_path
    end
  end
end