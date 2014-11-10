require 'spec_helper'

describe User do
  it { should validate_presence_of(:email)}
  it { should validate_presence_of(:password)}
  it { should validate_presence_of(:full_name)}
  it { should validate_uniqueness_of(:email)}
  it { should have_many(:queue_items).order(:position)}

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
end