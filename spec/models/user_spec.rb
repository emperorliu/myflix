require 'spec_helper'

describe User do
  it { should validate_presence_of(:email)}
  it { should validate_presence_of(:password)}
  it { should validate_presence_of(:full_name)}
  it { should validate_uniqueness_of(:email)}
  it { should have_many(:queue_items).order(:position)}
  it { should have_many(:reviews).order("created_at DESC")}

  it_behaves_like "tokenable" do
    let(:object) { Fabricate(:user) }
  end

  describe "#queued_video?" do
    it "returns true when the user queued the video" do
      jeff = Fabricate(:user)
      south_park = Fabricate(:video)
      Fabricate(:queue_item, user: jeff, video: south_park)
      expect(jeff.queued_video?(south_park)).to be true
    end
    it "returns false when the user hasn't queued the video" do
      jeff = Fabricate(:user)
      south_park = Fabricate(:video)
      expect(jeff.queued_video?(south_park)).to be false
    end
  end

  describe "#follows?" do
    it "returns true if the user has a following relationship with another user" do
      jeff = Fabricate(:user)
      bob = Fabricate(:user)
      Fabricate(:relationship, leader: bob, follower: jeff)
      expect(jeff.follows?(bob)).to be true
    end

    it "returns false if the user does not have a following relationship with another user" do
      jeff = Fabricate(:user)
      bob = Fabricate(:user)
      Fabricate(:relationship, leader: jeff, follower: bob)
      expect(jeff.follows?(bob)).to be false
    end
  end

  describe "#follow" do

    it "follows another user" do
      jeff = Fabricate(:user)
      bob = Fabricate(:user)
      jeff.follow(bob)
      expect(jeff.follows?(bob)).to be true
    end

    it "does not follow one self" do
      jeff = Fabricate(:user)
      jeff.follow(jeff)
      expect(jeff.follows?(jeff)).to be false
    end
  end
end