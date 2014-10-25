require 'spec_helper'

describe Video do
  it "saves itself" do
    video = Video.new(title: "monk", description: "a great tv show")
    video.save
    expect(Video.first).to eq(video)
  end

  it "belongs to category" do
    dramas = Category.create(name: "dramas")
    monk = Video.create(title: "monk", description: "a great video")
    VideoCategory.create(video_id: 1, category_id: 1)
    expect(monk.categories).to eq(dramas)
  end
end