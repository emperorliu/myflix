require 'spec_helper'

describe RelationshipsController do
  describe "GET index" do
    it "sets @relationships to the current user's following relationships (relationships that a current user has where they are a follower)" do
      jeff = Fabricate(:user)
      set_current_user(jeff)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: jeff, leader: bob)
      get :index
      expect(assigns(:relationships)).to eq([relationship])
    end

    it_behaves_like "requires sign in" do
      let(:action) { get :index }
    end
  end

  describe "DELETE destroy" do
    it_behaves_like "requires sign in" do
      let(:action) { delete :destroy, id: 4}
    end

    it "deletes the relationship if the current user is the follower" do
      jeff = Fabricate(:user)
      set_current_user(jeff)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: jeff, leader: bob)
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(0)
    end

    it "redirects to the people page" do
      jeff = Fabricate(:user)
      set_current_user(jeff)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: jeff, leader: bob)
      delete :destroy, id: relationship.id
      expect(response).to redirect_to people_path  
    end

    it "does not delete the relationship if the current user is not the follower" do
      jeff = Fabricate(:user)
      set_current_user(jeff)
      bob = Fabricate(:user)
      charlie = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: charlie, leader: bob)
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(1)
    end
  end

  describe "POST create" do
    it_behaves_like "requires sign in" do
      let(:action) { post :create, leader_id: 2 }
    end

    it "creates a relationship that current user follows the leader" do
      jeff = Fabricate(:user)
      set_current_user(jeff)
      bob = Fabricate(:user)
      post :create, leader_id: bob.id
      expect(jeff.following_relationships.first.leader).to eq(bob)
    end

    it "redirects to the people page" do
      jeff = Fabricate(:user)
      set_current_user(jeff)
      bob = Fabricate(:user)
      post :create, leader_id: bob.id
      expect(response).to redirect_to people_path
    end

    it "does not create a relationship if the current user is already following the leader" do
      jeff = Fabricate(:user)
      set_current_user(jeff)
      bob = Fabricate(:user)
      Fabricate(:relationship, leader: bob, follower: jeff)
      post :create, leader_id: bob.id
      expect(Relationship.count).to eq(1)
    end

    it "does not allow one to follow himself" do
      jeff = Fabricate(:user)
      set_current_user(jeff)
      post :create, leader_id: jeff.id
      expect(Relationship.count).to eq(0)
    end
  end
end