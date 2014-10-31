require 'spec_helper'

describe Video do
  it { should have_many(:categories) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should have_many(:reviews).order("created_at DESC")}

  describe "search_by_title" do

    it "returns an empty array if there is no match" do
      futurama = Video.create(title: "futurama", description: "space travel")
      back_to_future = Video.create(title: "back to the future", description: "a cool movie")
      expect(Video.search_by_title("hello")).to eq([])
    end

    it "returns an array of one video for an exact match" do
      futurama = Video.create(title: "futurama", description: "space travel")
      back_to_future = Video.create(title: "back to the future", description: "a cool movie")
      expect(Video.search_by_title("FuTuRaMa")).to eq([futurama])
    end

    it "returns an array of one video for a partial match" do
      futurama = Video.create(title: "futurama", description: "space travel")
      back_to_future = Video.create(title: "back to the future", description: "a cool movie")
      expect(Video.search_by_title("urama")).to eq([futurama])
    end

    it "returns an array of all matches ordered by created_at" do
      futurama = Video.create(title: "futurama", description: "space travel", created_at: 1.day.ago)
      back_to_future = Video.create(title: "back to the future", description: "a cool movie")
      expect(Video.search_by_title("futur")).to eq([back_to_future, futurama])
    end

    it "returns an empty array for a search with an empty string" do
      futurama = Video.create(title: "futurama", description: "space travel")
      back_to_future = Video.create(title: "back to the future", description: "a cool movie")
      expect(Video.search_by_title("")).to eq([])
    end

  end
end

# describe Video do
#   it "saves itself" do
#     video = Video.new(title: "monk", description: "a great tv show")
#     video.save
#     expect(Video.first).to eq(video)
#   end

#   it "belongs to category" do
#     dramas = Category.create(name: "dramas")
#     monk = Video.create(title: "monk", description: "a great video")
#     VideoCategory.create(video_id: monk.id, category_id: dramas.id)
#     expect(monk.categories).to eq([dramas])
#   end
# end

