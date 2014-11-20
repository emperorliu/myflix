require 'spec_helper'

feature 'User following' do
  scenario "user follows and unfollows someone" do
    bob = Fabricate(:user)
    comedies = Category.create(name: "comedies")
    # comedies = Fabricate(:category, name: "comedies")
    south_park = Fabricate(:video, title: "South Park")
    VideoCategory.create(video_id: south_park.id, category_id: comedies.id)
    Fabricate(:review, user: bob, video: south_park)

    jeff = Fabricate(:user)
    sign_in(jeff)
    click_on_video_on_home_page(south_park)

    click_link bob.full_name
    click_link "Follow"
    expect(page).to have_content(bob.full_name)

    unfollow(bob)
    expect(page).not_to have_content(bob.full_name)

  end

  def unfollow(user)
    find("a[data-method='delete']").click
  end
end