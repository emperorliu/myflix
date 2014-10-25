require 'spec_helper'

describe Category do
  it "saves itself" do
    category = Category.new(name: "comedies")
    category.save
    expect(Category.first).to eq(category)
  end

  it "has many videos" do
    comedies = Category.create(name: "comedies")
    south_park = Video.create(title: "south park", description: "a funny show")
    futurama = Video.create(title: "futurama", description: "space travel")
    VideoCategory.create(video_id: 1, category_id: 1)
    VideoCategory.create(video_id: 2, category_id: 1)
    expect(comedies.videos).to eq([futurama, south_park])
  end
end