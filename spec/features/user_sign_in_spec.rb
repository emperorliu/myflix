require 'spec_helper'

feature "user signs in" do
  scenario "with valid email and password" do
    jeff = Fabricate(:user)
    visit sign_in_path
    fill_in "Email Address", with: jeff.email
    fill_in "Confirm Password", with: jeff.password
    click_button "Sign in"
    expect(page).to have_content jeff.full_name
  end
end