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

  describe "POST create" do
    
    it "redirects to my_queue path" do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(response).to redirect_to my_queue_path
    end

    it "should create a queue item" do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.count).to eq(1)
    end

    it "creates the queue item that is association with the video" do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.first.video).to eq(video)
    end

    it "creates the queue item that is associated with the sign in user" do
      jeff = Fabricate(:user)
      session[:user_id] = jeff.id
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.first.user).to eq(jeff)
    end

    it "puts the video as the last one in the queue" do
      jeff = Fabricate(:user)
      session[:user_id] = jeff.id
      video1 = Fabricate(:video)
      Fabricate(:queue_item, video: video1, user: jeff)
      video2 = Fabricate(:video)
      post :create, video_id: video2.id
      video2_queue_item = QueueItem.where(video_id: video2, user_id: jeff.id).first
      expect(video2_queue_item.position).to eq(2)
    end

    it "does not add the video to the queue if the video is already in the queue" do
      jeff = Fabricate(:user)
      session[:user_id] = jeff.id
      video1 = Fabricate(:video)
      Fabricate(:queue_item, video: video1, user: jeff)
      post :create, video_id: video1.id
      expect(jeff.queue_items.count).to eq(1)
    end

    it "redirects to the sign in page for unauthenticated users" do
      post :create, video_id: 3
      expect(response).to redirect_to sign_in_path
    end
  end

  describe "DELETE destroy" do

    it "redirects to the my queue page" do
      session[:user_id] = Fabricate(:user).id
      queue_item = Fabricate(:queue_item)
      delete :destroy, id: queue_item.id
      expect(response).to redirect_to my_queue_path
    end

    it "deletes the queue item" do
      jeff = Fabricate(:user)
      session[:user_id] = jeff.id
      queue_item = Fabricate(:queue_item, user: jeff)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end

    it "normalizes the remaining queue items" do
      jeff = Fabricate(:user)
      session[:user_id] = jeff.id
      queue_item1 = Fabricate(:queue_item, user: jeff, position: 1)
      queue_item2 = Fabricate(:queue_item, user: jeff, position: 2)
      delete :destroy, id: queue_item1.id
      expect(queue_item2.reload.position).to eq(1)
    end

    it "does not delete the queue item if the queue item isn't in the current user's queue" do
      jeff = Fabricate(:user)
      bob = Fabricate(:user)
      session[:user_id] = jeff.id
      queue_item = Fabricate(:queue_item, user: bob)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(1)
    end

    it "redirects to the sign in page for unauthenticated users" do
      delete :destroy, id: 3
      expect(response).to redirect_to sign_in_path
    end
  end

  describe "POST update_queue" do
    context "with valid inputs" do

      it "redirects to the my queue page" do
        jeff = Fabricate(:user)
        session[:user_id] = jeff.id
        queue_item1 = Fabricate(:queue_item, user: jeff, position: 1)
        queue_item2 = Fabricate(:queue_item, user: jeff, position: 2)
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
        expect(response).to redirect_to my_queue_path
      end

      it "reorders the queue items" do
        jeff = Fabricate(:user)
        session[:user_id] = jeff.id
        queue_item1 = Fabricate(:queue_item, user: jeff, position: 1)
        queue_item2 = Fabricate(:queue_item, user: jeff, position: 2)
        post :update_queue, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
        expect(jeff.queue_items).to eq([queue_item2, queue_item1])
      end

      it "normalizes the position numbers" do
        jeff = Fabricate(:user)
        session[:user_id] = jeff.id
        queue_item1 = Fabricate(:queue_item, user: jeff, position: 1)
        queue_item2 = Fabricate(:queue_item, user: jeff, position: 2)
        post :update_queue, queue_items: [{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2}]
        # expect(queue_item1.reload.position).to eq(2) 
        # expect(queue_item2.reload.position).to eq(1) must reload because of the way it's retrieving from the database, the items didn't change even tho it did in the db. can go from the jeff path.
        expect(jeff.queue_items.map(&:position)).to eq([1,2])
      end
    end

    context "with invalid inputs" do
      it "redirects to the my queue page" do
        jeff = Fabricate(:user)
        session[:user_id] = jeff.id
        queue_item1 = Fabricate(:queue_item, user: jeff, position: 1)
        queue_item2 = Fabricate(:queue_item, user: jeff, position: 2)
        post :update_queue, queue_items: [{id: queue_item1.id, position: 3.4}, {id: queue_item2.id, position: 1}]
        expect(response).to redirect_to my_queue_path
      end

      it "sets the flash error message" do
        jeff = Fabricate(:user)
        session[:user_id] = jeff.id
        queue_item1 = Fabricate(:queue_item, user: jeff, position: 1)
        queue_item2 = Fabricate(:queue_item, user: jeff, position: 2)
        post :update_queue, queue_items: [{id: queue_item1.id, position: 3.4}, {id: queue_item2.id, position: 1}]
        expect(flash[:danger]).to be_present
      end

      it "does not change the queue items" do
        jeff = Fabricate(:user)
        session[:user_id] = jeff.id
        queue_item1 = Fabricate(:queue_item, user: jeff, position: 1)
        queue_item2 = Fabricate(:queue_item, user: jeff, position: 2)
        post :update_queue, queue_items: [{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2.1}]
        expect(queue_item1.reload.position).to eq(1)
      end

    end

    context "with unauthenticated users" do
      it "should redirect to signin page" do
        post :update_queue, queue_items: [{id: 2, position: 3}, {id: 1, position: 2}]
        expect(response).to redirect_to sign_in_path
      end
    end

    context "with queue items that do not belong to the current user" do
      it "does not change the queue items" do
        jeff = Fabricate(:user)
        session[:user_id] = jeff.id
        bob = Fabricate(:user)
        queue_item1 = Fabricate(:queue_item, user: bob, position: 1)
        queue_item2 = Fabricate(:queue_item, user: jeff, position: 2)
        post :update_queue, queue_items: [{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2}]
        expect(queue_item1.reload.position).to eq(1)
        # adds the implementation code "if queue_item.user == current_user"
      end
    end
  end
end