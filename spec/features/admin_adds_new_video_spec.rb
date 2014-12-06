require 'spec_helper'

feature "admin adds new video" do
  scenario "admin adds a new video" do
    admin = Fabricate(:admin)
    comedies = Fabricate(:category, name: "Comedies")
    sign_in(admin)
    visit new_admin_video_path

    fill_in "Title", with: "South Park"
    select("Comedies", :from => 'Categories')
    fill_in "Description", with: "This is a funny show!"
    attach_file "Large cover", "#{Rails.root}/public/tmp/south_park_large.jpg"
    attach_file "Small cover", "#{Rails.root}/public/tmp/south_park.jpg"
    fill_in "Video url", with: "http://www.example.com/my_video.mp4"
    click_button "Add Video"

    sign_out
    sign_in

    visit video_path(Video.first)
    expect(page).to have_selector("img[src='/uploads/south_park_large.jpg']")
    expect(page).to have_content "South Park"

    click_link "Watch Now"
    expect(page).to have_xpath("//source[contains(@src, 'http://www.example.com/my_video.mp4')]")
  end
end